import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { QrController } from './qr.controller';
import { QrService } from './qr.service';
import { QrToken, QrTokenSchema } from './qr-token.schema';
import { Child, ChildSchema } from '../child/child.schema';
import { Parent, ParentSchema } from '../parent/parent.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: QrToken.name, schema: QrTokenSchema },
      { name: Child.name, schema: ChildSchema },
      { name: Parent.name, schema: ParentSchema },
    ]),
    ConfigModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => {
        // 🔥 MÊME SECRET ET MÊME EXPIRATION QUE auth.module.ts
        const secret = configService.get<string>('JWT_SECRET') || 'your-secret-key';
        const expiresIn = configService.get<string>('JWT_EXPIRES_IN') || '24h';
        
        console.log('🔑 [QR Module] JWT Secret configured');
        console.log('⏱️  [QR Module] JWT Expires In:', expiresIn);
        
        return {
          secret: secret,
          signOptions: { 
            expiresIn: expiresIn,
            algorithm: 'HS256',
          },
        };
      },
    }),
  ],
  controllers: [QrController],
  providers: [QrService],
  exports: [QrService],
})
export class QrModule {}
