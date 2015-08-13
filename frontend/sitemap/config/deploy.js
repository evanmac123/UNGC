module.exports = {
  development: {
    buildEnv: 'development',
    store: {
      type: 'redis',  // this can be omitted because it is the default
      host: 'localhost',
      port: 6379
    }
  },

  preview: {
    buildEnv: 'preview', // Override the environment passed to the ember asset build. Defaults to 'production'
    store: {
      type: 'redis',
      host: 'localhost',
      port: 6380
    },
    assets: {
      accessKeyId: 'AKIAIAHEVV5B2KXIPNGA',
      secretAccessKey: process.env['AWS_SECRET_KEY'],
      bucket: 'ungc-development'
    }
  },

  staging: {
    buildEnv: 'staging', // Override the environment passed to the ember asset build. Defaults to 'production'
    store: {
      type: 'redis',
      host: 'localhost',
      port: 6380
    },
    assets: {
      accessKeyId: 'AKIAIAHEVV5B2KXIPNGA',
      secretAccessKey: process.env['AWS_SECRET_KEY'],
      bucket: 'ungc-development'
    }
  },

  production: {
    buildEnv: 'production', // Override the environment passed to the ember asset build. Defaults to 'production'
    store: {
      type: 'redis',
      host: 'localhost',
      port: 6380
    },
    assets: {
      accessKeyId: 'AKIAIAHEVV5B2KXIPNGA',
      secretAccessKey: process.env['AWS_SECRET_KEY'],
      bucket: 'ungc-production'
    }
  }
};
