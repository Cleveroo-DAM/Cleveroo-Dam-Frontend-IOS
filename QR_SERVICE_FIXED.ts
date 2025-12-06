import { BadRequestException, Injectable, NotFoundException, ForbiddenException, InternalServerErrorException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { QrToken, QrTokenDocument } from './qr-token.schema';
import { Child } from '../child/child.schema';
import { Parent } from '../parent/parent.schema';
import * as crypto from 'crypto';
import QRCode from 'qrcode';
import { JwtService } from '@nestjs/jwt';
import { Logger } from '@nestjs/common';

@Injectable()
export class QrService {
  private readonly logger = new Logger(QrService.name);

  constructor(
    @InjectModel(QrToken.name) private qrModel: Model<QrTokenDocument>,
    @InjectModel(Child.name) private childModel: Model<Child & { _id: Types.ObjectId }>,
    @InjectModel(Parent.name) private parentModel: Model<Parent & { _id: Types.ObjectId }>,
    private readonly jwtService: JwtService,
  ) {}

  async generateTokenForChild(params: { parentId: string; childId: string; ttlSeconds?: number; returnQrImage?: boolean }) {
    try {
      this.logger.log(`[generateTokenForChild] START - parentId=${params.parentId}, childId=${params.childId}`);

      const parent = await this.parentModel.findById(params.parentId).exec();
      if (!parent) {
        this.logger.error('[generateTokenForChild] Parent not found');
        throw new NotFoundException('Parent not found');
      }

      const child = await this.childModel.findById(params.childId).exec();
      if (!child) {
        this.logger.error('[generateTokenForChild] Child not found');
        throw new NotFoundException('Child not found');
      }

      const childIdObj = child._id as Types.ObjectId;
      const isChildOfParent = (parent.children as any[] || []).some((c: any) => c.toString() === childIdObj.toString());
      if (!isChildOfParent) {
        this.logger.error('[generateTokenForChild] Child does not belong to parent');
        throw new ForbiddenException('Child does not belong to parent');
      }

      // Génère un token permanent (pas d'expiresAt)
      const token = crypto.randomBytes(32).toString('hex');
      this.logger.log(`[generateTokenForChild] Generated token: ${token.substring(0, 20)}...`);

      await this.qrModel.create({
        token,
        childId: childIdObj,
        parentId: parent._id,
        used: false,
      });
      this.logger.log(`[generateTokenForChild] Token saved to database`);

      let qrDataUri: string | undefined = undefined;
      if (params.returnQrImage) {
        try {
          this.logger.log(`[generateTokenForChild] Generating QR image...`);
          const payload = token;
          qrDataUri = await QRCode.toDataURL(payload, { type: 'image/png', width: 300 });
          this.logger.log(`[generateTokenForChild] QR image generated successfully`);
        } catch (qrErr) {
          this.logger.warn('Failed to generate QR image, returning token only: ' + (qrErr?.stack ?? qrErr));
        }
      }

      this.logger.log(`[generateTokenForChild] SUCCESS`);
      return { token, qrDataUri };
    } catch (err) {
      this.logger.error('generateTokenForChild error', err?.stack ?? err);
      throw err;
    }
  }

  /**
   * Exchange QR token for JWT.
   * NOTE: This version allows the same token to be exchanged multiple times (reusable).
   * FIX: Added .exec() to ensure promise is returned
   */
  async exchangeTokenForJwt(token: string) {
    try {
      if (!token) {
        this.logger.warn('exchangeTokenForJwt called without token or empty token');
        throw new BadRequestException('Token required');
      }

      const trimmed = token.trim();
      this.logger.log(`[exchangeTokenForJwt] START - token=${trimmed.substring(0, 20)}...`);

      // FIX: Added .exec() to ensure the query completes
      this.logger.log(`[exchangeTokenForJwt] Querying database for token...`);
      const record = await this.qrModel.findOne({ token: trimmed }).lean().exec();
      
      if (!record) {
        this.logger.warn(`[exchangeTokenForJwt] Token not found: ${trimmed.substring(0, 20)}...`);
        throw new NotFoundException('Invalid token');
      }

      this.logger.log(`[exchangeTokenForJwt] Token found, fetching child...`);

      // Ensure child exists
      const child = await this.childModel.findById(record.childId).exec();
      if (!child) {
        this.logger.error(`[exchangeTokenForJwt] Child not found for token record childId=${record.childId}`);
        throw new NotFoundException('Child not found for token');
      }

      const childIdStr = (child._id as Types.ObjectId).toString();
      this.logger.log(`[exchangeTokenForJwt] Child found: ${childIdStr}, signing JWT...`);

      const payload = { sub: childIdStr, id: childIdStr, username: (child as any).username ?? null };

      try {
        const access_token = this.jwtService.sign(payload);
        this.logger.log(`[exchangeTokenForJwt] SUCCESS - JWT signed for childId=${childIdStr}`);
        return { access_token, childId: childIdStr };
      } catch (jwtErr) {
        this.logger.error('[exchangeTokenForJwt] JWT sign failed', jwtErr?.stack ?? jwtErr);
        throw new InternalServerErrorException('Failed to sign JWT');
      }
    } catch (err) {
      this.logger.error('[exchangeTokenForJwt] ERROR', err?.stack ?? err);
      throw err;
    }
  }

  /**
   * Invalidate tokens for a child.
   * For reusable tokens we choose to delete them to revoke access.
   */
  async revokeTokensForChild(childId: string) {
    try {
      this.logger.log(`[revokeTokensForChild] START - childId=${childId}`);
      const result = await this.qrModel.deleteMany({ childId: new Types.ObjectId(childId) }).exec();
      this.logger.log(`[revokeTokensForChild] SUCCESS - deleted ${result.deletedCount} tokens`);
      return { message: 'Tokens revoked (deleted)', deletedCount: result.deletedCount };
    } catch (err) {
      this.logger.error('[revokeTokensForChild] ERROR', err?.stack ?? err);
      throw err;
    }
  }
}
