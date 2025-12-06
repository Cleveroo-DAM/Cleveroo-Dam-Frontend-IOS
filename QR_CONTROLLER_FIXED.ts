import { Body, Controller, Delete, Get, Param, Post, Request, UseGuards, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { ApiBearerAuth, ApiBody, ApiOperation, ApiTags, ApiResponse } from '@nestjs/swagger';
import { QrService } from './qr.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ExchangeTokenDto } from './dto/exchange-token.dto';

@ApiTags('qr')
@Controller('qr')
export class QrController {
  private readonly logger = new Logger(QrController.name);

  constructor(private readonly qrService: QrService) {}

  /**
   * Generate QR token for a child (Parent only)
   * POST /qr/children/:childId/generate
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('children/:childId/generate')
  @ApiOperation({ summary: 'Generate QR token for a child' })
  @ApiResponse({ status: 200, description: 'QR token generated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - child not yours' })
  @ApiResponse({ status: 404, description: 'Parent or child not found' })
  async generate(
    @Request() req: any,
    @Param('childId') childId: string,
    @Body() body: { ttlSeconds?: number; returnQrImage?: boolean },
  ) {
    try {
      const parentId = req.user.id;
      this.logger.log(`[QR Generate] parent=${parentId}, child=${childId}`);
      
      const result = await this.qrService.generateTokenForChild({
        parentId,
        childId,
        ttlSeconds: body?.ttlSeconds,
        returnQrImage: body?.returnQrImage ?? true,
      });
      
      this.logger.log(`[QR Generate Success] token generated successfully`);
      return result;
    } catch (err) {
      this.logger.error('[QR Generate Error]', err?.stack ?? err?.message ?? err);
      throw err;
    }
  }

  /**
   * Exchange QR token for JWT (Child login via QR)
   * POST /qr/exchange
   * Public endpoint - no auth required
   * Returns: { access_token, childId }
   */
  @Post('exchange')
  @ApiOperation({ summary: 'Exchange QR token for JWT (child login via QR code)' })
  @ApiBody({ type: ExchangeTokenDto })
  @ApiResponse({ status: 200, description: 'Token exchanged successfully, returns JWT' })
  @ApiResponse({ status: 400, description: 'Invalid token format' })
  @ApiResponse({ status: 404, description: 'Token not found' })
  @ApiResponse({ status: 500, description: 'Server error' })
  async exchange(@Body() body: ExchangeTokenDto) {
    try {
      this.logger.log(`[QR Exchange] START - token=${body.token?.substring(0, 20)}...`);
      
      if (!body || !body.token) {
        this.logger.warn('[QR Exchange] No token provided in request body');
        throw new HttpException('Token is required', HttpStatus.BAD_REQUEST);
      }

      const result = await this.qrService.exchangeTokenForJwt(body.token);
      
      this.logger.log(`[QR Exchange Success] childId=${result.childId}`);
      return result;
    } catch (err) {
      this.logger.error('[QR Exchange Error]', err?.stack ?? err?.message ?? err);
      
      // Re-throw NestJS exceptions as-is, wrap others
      if (err instanceof HttpException) {
        throw err;
      }
      
      // Default error response
      throw new HttpException(
        err?.message ?? 'Failed to exchange token',
        err?.status ?? HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  /**
   * Revoke QR tokens for a child (Parent only)
   * DELETE /qr/children/:childId/tokens
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Delete('children/:childId/tokens')
  @ApiOperation({ summary: 'Revoke all QR tokens for a child' })
  @ApiResponse({ status: 200, description: 'Tokens revoked successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async revokeTokens(
    @Param('childId') childId: string,
    @Request() req: any,
  ) {
    try {
      const parentId = req.user.id;
      this.logger.log(`[QR Revoke] parent=${parentId}, child=${childId}`);
      
      const result = await this.qrService.revokeTokensForChild(childId);
      
      this.logger.log(`[QR Revoke Success]`);
      return result;
    } catch (err) {
      this.logger.error('[QR Revoke Error]', err?.stack ?? err?.message ?? err);
      throw err;
    }
  }

  /**
   * Health check endpoint for QR service
   * GET /qr/health
   */
  @Get('health')
  @ApiOperation({ summary: 'Health check for QR service' })
  @ApiResponse({ status: 200, description: 'Service is healthy' })
  health() {
    this.logger.log('[QR Health] OK');
    return { status: 'ok', service: 'qr', timestamp: new Date().toISOString() };
  }
}
