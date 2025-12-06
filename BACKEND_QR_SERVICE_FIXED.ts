import {
  BadRequestException,
  Injectable,
  NotFoundException,
  ForbiddenException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { QrToken, QrTokenDocument } from './qr-token.schema';
import { Child } from '../child/child.schema';
import { Parent } from '../parent/parent.schema';
import * as crypto from 'crypto';
import QRCode from 'qrcode';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class QrService {
  private readonly logger = new Logger(QrService.name);

  constructor(
    @InjectModel(QrToken.name) private qrModel: Model<QrTokenDocument>,
    @InjectModel(Child.name) private childModel: Model<Child & { _id: Types.ObjectId }>,
    @InjectModel(Parent.name) private parentModel: Model<Parent & { _id: Types.ObjectId }>,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Generate a permanent QR token for a child
   * Tokens are reusable and don't expire
   */
  async generateTokenForChild(params: {
    parentId: string;
    childId: string;
    ttlSeconds?: number; // Ignored - tokens are permanent
    returnQrImage?: boolean;
  }) {
    try {
      this.logger.log(`[generateTokenForChild] START - parentId=${params.parentId}, childId=${params.childId}`);

      // Verify parent exists
      const parent = await this.parentModel.findById(params.parentId);
      if (!parent) {
        this.logger.error('[generateTokenForChild] Parent not found');
        throw new NotFoundException('Parent not found');
      }

      // Verify child exists
      const child = await this.childModel.findById(params.childId);
      if (!child) {
        this.logger.error('[generateTokenForChild] Child not found');
        throw new NotFoundException('Child not found');
      }

      // Verify child belongs to parent
      const childIdObj = child._id as Types.ObjectId;
      const isChildOfParent = (parent.children as any[] || []).some(
        (c: any) => c.toString() === childIdObj.toString(),
      );
      if (!isChildOfParent) {
        this.logger.error('[generateTokenForChild] Child does not belong to parent');
        throw new ForbiddenException('Child does not belong to parent');
      }

      // Generate permanent token (no expiration)
      const token = crypto.randomBytes(32).toString('hex');
      this.logger.log(`[generateTokenForChild] Generated token: ${token.substring(0, 20)}...`);

      // Save token to database
      const qrRecord = await this.qrModel.create({
        token,
        childId: childIdObj,
        parentId: parent._id,
        used: false, // Tokens are reusable, so this is ignored
      });
      this.logger.log(`[generateTokenForChild] Token saved to DB, id=${qrRecord._id}`);

      // Generate QR image if requested
      let qrDataUri: string | undefined = undefined;
      if (params.returnQrImage) {
        try {
          this.logger.log(`[generateTokenForChild] Generating QR image...`);
          qrDataUri = await QRCode.toDataURL(token, {
            type: 'image/png',
            width: 300,
            margin: 2,
            errorCorrectionLevel: 'H',
          });
          this.logger.log(`[generateTokenForChild] QR image generated successfully`);
        } catch (qrErr) {
          this.logger.warn(
            `[generateTokenForChild] Failed to generate QR image: ${qrErr?.message ?? qrErr}`,
          );
          // Don't throw - return token without image
        }
      }

      this.logger.log(`[generateTokenForChild] SUCCESS`);
      return { token, qrDataUri };
    } catch (err) {
      this.logger.error(`[generateTokenForChild] ERROR: ${err?.message ?? err}`, err?.stack);
      throw err;
    }
  }

  /**
   * Exchange QR token for JWT
   * Tokens are reusable - same token can be used multiple times
   */
  async exchangeTokenForJwt(token: string) {
    try {
      if (!token || typeof token !== 'string') {
        this.logger.warn('[exchangeTokenForJwt] Invalid token format');
        throw new BadRequestException('Token is required and must be a string');
      }

      const trimmedToken = token.trim();
      if (trimmedToken.length === 0) {
        this.logger.warn('[exchangeTokenForJwt] Empty token after trim');
        throw new BadRequestException('Token cannot be empty');
      }

      this.logger.log(`[exchangeTokenForJwt] START - token=${trimmedToken.substring(0, 20)}...`);

      // Find token record in database
      this.logger.log(`[exchangeTokenForJwt] Querying database...`);
      const record = await this.qrModel.findOne({ token: trimmedToken }).lean().exec();

      if (!record) {
        this.logger.warn(`[exchangeTokenForJwt] Token not found in database`);
        throw new NotFoundException('Invalid QR token');
      }

      this.logger.log(`[exchangeTokenForJwt] Token found, childId=${record.childId}`);

      // Verify child still exists
      const child = await this.childModel.findById(record.childId).lean().exec();
      if (!child) {
        this.logger.error(`[exchangeTokenForJwt] Child not found for token`);
        throw new NotFoundException('Child associated with token not found');
      }

      const childIdStr = (child._id as Types.ObjectId).toString();
      this.logger.log(`[exchangeTokenForJwt] Child found: ${child.username ?? 'unknown'}`);

      // Generate JWT
      const payload = {
        sub: childIdStr,
        id: childIdStr,
        username: child.username ?? null,
      };

      this.logger.log(`[exchangeTokenForJwt] Signing JWT with payload: ${JSON.stringify(payload)}`);
      const access_token = this.jwtService.sign(payload);

      this.logger.log(`[exchangeTokenForJwt] SUCCESS - JWT created for childId=${childIdStr}`);
      return {
        access_token,
        childId: childIdStr,
      };
    } catch (err) {
      this.logger.error(`[exchangeTokenForJwt] ERROR: ${err?.message ?? err}`, err?.stack);
      throw err;
    }
  }

  /**
   * Revoke all QR tokens for a child
   * Deletes tokens so they can no longer be used
   */
  async revokeTokensForChild(childId: string) {
    try {
      this.logger.log(`[revokeTokensForChild] START - childId=${childId}`);

      const objectId = new Types.ObjectId(childId);
      const result = await this.qrModel.deleteMany({ childId: objectId });

      this.logger.log(`[revokeTokensForChild] SUCCESS - deleted ${result.deletedCount} tokens`);
      return {
        message: 'All QR tokens revoked',
        deletedCount: result.deletedCount,
      };
    } catch (err) {
      this.logger.error(`[revokeTokensForChild] ERROR: ${err?.message ?? err}`, err?.stack);
      throw err;
    }
  }
}
