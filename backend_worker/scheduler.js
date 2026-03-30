const admin = require('firebase-admin');
const cron = require('node-cron');

// 1. INITIALIZE FIREBASE ADMIN
// NOTE: You must generate a service-account.json from Firebase Console:
// Project Settings > Service Accounts > Generate New Private Key
// Save it as 'service-account.json' in this folder.
const serviceAccount = require("./service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

console.log('Postly Scheduler Worker initialized.');
console.log('Running every 60 seconds...');

// 2. SCHEDULER CRON JOB
cron.schedule('* * * * *', async () => {
  const now = admin.firestore.Timestamp.now();
  console.log(`[${new Date().toISOString()}] Checking for pending posts...`);

  try {
    // 3. QUERY PENDING POSTS
    // Requires a Collection Group index on 'scheduled_posts' (status + scheduledFor)
    const snapshot = await db
      .collectionGroup('scheduled_posts')
      .where('status', '==', 'pending')
      .where('scheduledFor', '<=', now)
      .orderBy('scheduledFor', 'asc')
      .limit(10) // Process in small batches
      .get();

    if (snapshot.empty) {
      console.log('No pending posts found.');
      return;
    }

    console.log(`Found ${snapshot.size} posts to process.`);

    for (const doc of snapshot.docs) {
      const postRef = doc.ref;
      const postData = doc.data();
      
      console.log(`[${doc.id}] Processing post: "${postData.content.substring(0, 30)}..."`);

      try {
        // 4. IDEMPOTENCY: Set to 'publishing' immediately to prevent other worker instances from picking it up
        await postRef.update({ status: 'publishing' });

        // 5. PUBLISH LOGIC (Stub for Phase 5 integration)
        // Here we would call Meta/TikTok APIs using tokens from postData or company profile
        console.log(`[${doc.id}] Publishing to platforms: ${postData.targetPlatforms.join(', ')}`);
        
        // Simulating network delay
        await new Promise(resolve => setTimeout(resolve, 2000));

        // 6. SUCCESS UPDATE
        await postRef.update({
          status: 'published',
          publishedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`[${doc.id}] Successfully published.`);

      } catch (postError) {
        console.error(`[${doc.id}] Error publishing:`, postError.message);
        await postRef.update({
          status: 'failed',
          error: postError.message
        });
      }
    }

  } catch (error) {
    console.error('CRITICAL ERROR in Scheduler:', error.message);
  }
});
