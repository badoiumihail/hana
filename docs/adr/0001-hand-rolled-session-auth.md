# Hand-rolled session auth instead of an auth library

Hana is a learning project, and authentication is where backend, database and frontend security meet, so we implement session auth ourselves: argon2 password hashing, a sessions table in Postgres, and httpOnly cookies. A library or hosted provider (Better Auth, Clerk, Auth0) would be the sensible choice for a product, and that is exactly why this needs recording: the point is to understand what those tools do before relying on one. OAuth, password reset and 2FA are out of scope until later.
