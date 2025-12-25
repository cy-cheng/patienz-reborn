#!/bin/bash

# Patienz Setup Script

echo "🏥 Patienz - Virtual Patient Interview System Setup"
echo "=================================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✓ .env file created"
    echo ""
    echo "⚠️  Please add your Gemini API key to .env:"
    echo "   1. Go to: https://aistudio.google.com/apikey"
    echo "   2. Create an API key"
    echo "   3. Edit .env and set GEMINI_API_KEY=your_key_here"
    echo ""
fi

# Install dependencies
echo "📦 Installing Ruby gems..."
bundle install
if [ $? -eq 0 ]; then
    echo "✓ Gems installed successfully"
else
    echo "✗ Failed to install gems"
    exit 1
fi

echo ""

# Setup database
echo "🗄️  Setting up database..."
rails db:create 2>/dev/null
rails db:migrate 2>/dev/null
echo "✓ Database ready"

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To start the server, run:"
echo "   rails server"
echo ""
echo "📖 Visit http://localhost:3000 to get started"
echo ""
