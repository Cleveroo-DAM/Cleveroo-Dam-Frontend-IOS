import { Body, Controller, Delete, Get, Param, Post, Request, UseGuards, Logger } from '@nestjs/common';
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
  async generate(
    @Request() req: any,
    @Param('childId') childId: string,
    @Body() body: { ttlSeconds?: number; returnQrImage?: boolean },
  ) {
    try {
      const parentId = req.user.id;
      this.logger.log(`[QR Generate] parent=${parentId}, child=${childId}, body=${JSON.stringify(body)}`);
      
      const result = await this.qrService.generateTokenForChild({
        parentId,
        childId,
        ttlSeconds: body?.ttlSeconds,
        returnQrImage: body?.returnQrImage ?? true,
      });
      
      this.logger.log(`[QR Generate Success] token=${result.token?.substring(0, 20)}...`);
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
   */
  @Post('exchange')
  @ApiOperation({ summary: 'Exchange QR token for JWT (child login)' })
  @ApiBody({ type: ExchangeTokenDto })
  @ApiResponse({ status: 200, description: 'Token exchanged successfully, returns { access_token, childId }' })
  @ApiResponse({ status: 400, description: 'Invalid token' })
  @ApiResponse({ status: 404, description: 'Token not found' })
  async exchange(@Body() body: ExchangeTokenDto) {
    try {
      this.logger.log(`[QR Exchange] token=${body.token?.substring(0, 20)}...`);
      
      const result = await this.qrService.exchangeTokenForJwt(body.token);
      
      this.logger.log(`[QR Exchange Success] childId=${result.childId}`);
      return result;
    } catch (err) {
      this.logger.error('[QR Exchange Error]', err?.stack ?? err?.message ?? err);
      throw err;
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
  health() {
    return { status: 'ok', service: 'qr' };
  }
}
