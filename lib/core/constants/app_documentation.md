# Transfort App Documentation

## Project Overview
Transfort is a logistics platform connecting load suppliers with truck owners in India. Built with Flutter and Supabase.

## Architecture

### Frontend
- **Framework:** Flutter 3.38.7
- **State Management:** Riverpod 2.6.1
- **Routing:** GoRouter 13.2.5
- **UI:** Custom glassmorphic design with gradient themes

### Backend
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage
- **Real-time:** Supabase Realtime

## Key Features

### For Suppliers
- Post loads with details (material, weight, route)
- View and manage posted loads
- Chat with truckers
- Rate and review truckers
- Track load status

### For Truckers
- Browse available loads
- Manage fleet (add/edit trucks)
- Apply for loads
- Chat with suppliers
- Rate and review suppliers

### For Admins
- KYC verification management
- User management
- Analytics dashboard
- System configuration

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # Constants and labels
│   ├── errors/          # Error handling
│   ├── router/          # Navigation routing
│   ├── services/        # Core services
│   ├── theme/           # App theming
│   └── utils/           # Utility functions
├── features/
│   ├── admin/           # Admin features
│   ├── auth/            # Authentication
│   ├── chat/            # Messaging
│   ├── fleet/           # Fleet management
│   ├── loads/           # Load management
│   ├── profile/         # User profiles
│   ├── ratings/         # Rating system
│   └── verification/    # KYC verification
└── shared/
    └── widgets/         # Reusable widgets
```

## Database Schema

### Main Tables
- `users` - User profiles and authentication
- `loads` - Load postings
- `trucks` - Fleet management
- `chats` - Chat conversations
- `chat_messages` - Individual messages
- `ratings` - User ratings and reviews
- `notifications` - User notifications
- `verification_requests` - KYC verification
- `analytics_events` - Usage analytics

## Security Features

### Implemented
- Row Level Security (RLS) on all tables
- Input sanitization (XSS/SQL injection prevention)
- Rate limiting on authentication (5 attempts/5 min)
- HTTPS enforcement
- Log sanitization (sensitive data redaction)
- Password complexity requirements
- Biometric authentication support
- Offline data caching with encryption

### Data Protection
- GDPR-compliant data retention policies
- User data anonymization on deletion
- Automated cleanup of old data
- Secure document storage

## API Integration

### Supabase
- Authentication API
- Database API (PostgreSQL)
- Storage API
- Realtime subscriptions

### Google Services
- AdMob for monetization
- Google Fonts

## Testing

### Unit Tests
- Utility functions
- Business logic
- Data models

### Widget Tests
- UI components
- Screen interactions
- Navigation flows

### Integration Tests
- End-to-end user flows
- API integration
- Database operations

## Deployment

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- APK Size: ~59MB
- Build: Release with R8 optimization

### Environment Configuration
- Development: `assets/env/local.env`
- Production: `assets/env/production.env`

## Performance Optimizations

### App
- Image optimization and compression
- Lazy loading of data
- Cursor-based pagination
- Selective state watching
- Widget caching

### Database
- Indexed queries
- Optimized RLS policies
- Connection pooling
- Query result caching

## Monitoring

### Analytics
- User behavior tracking
- Feature usage metrics
- Error tracking
- Performance monitoring

### Logging
- Structured logging
- Log levels (debug, info, warning, error)
- Sensitive data redaction
- Remote log aggregation

## Maintenance

### Regular Tasks
- Database cleanup (automated)
- Log rotation
- Cache invalidation
- Dependency updates

### Monitoring
- Server health checks
- Database performance
- API response times
- Error rates

## Support

### User Support
- In-app help documentation
- FAQ section
- Contact support form
- Chat support

### Developer Support
- Code documentation
- API documentation
- Architecture diagrams
- Deployment guides

## Future Enhancements

### Planned Features
- Multi-language support (Hindi, regional languages)
- Advanced search and filters
- Route optimization
- Real-time tracking
- Payment integration
- Insurance integration

### Technical Improvements
- Comprehensive test coverage
- CI/CD pipeline
- Automated deployments
- Performance monitoring
- Crash reporting

## Contributing

### Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

### Git Workflow
- Feature branches
- Pull request reviews
- Semantic commit messages
- Version tagging

## License
Proprietary - All rights reserved

## Contact
For questions or support, contact the development team.

---

**Last Updated:** January 22, 2026  
**Version:** 1.0.0  
**Status:** Production Ready
