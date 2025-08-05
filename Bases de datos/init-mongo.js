// Initialize databases and users for microservices
const databases = [
  'microservicio1',
  'microservicio2',
  'microservicio3',
  'microservicio4',
  'microservicio5'
];

// Create database users for each microservice
databases.forEach(dbName => {
  db = db.getSiblingDB(dbName);
  
  // Create a user with read/write access to their own database
  db.createUser({
    user: `user_${dbName}`,
    pwd: `password_${dbName}`,
    roles: [{
      role: 'readWrite',
      db: dbName
    }]
  });
  
  // Create a collection in each database
  db.createCollection('logs');
  
  print(`Database ${dbName} initialized`);
});

// Create admin user for all databases
admin = db.getSiblingDB('admin');
admin.createUser({
  user: process.env.MONGO_ROOT_USERNAME || 'admin',
  pwd: process.env.MONGO_ROOT_PASSWORD || 'admin123',
  roles: [{
    role: 'root',
    db: 'admin'
  }]
});

print('MongoDB initialization complete');
