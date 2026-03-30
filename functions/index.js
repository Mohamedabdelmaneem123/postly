const { onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require('firebase-admin');

admin.initializeApp();

// AI Content Generation
exports.generatePost = onCall(async (request) => {
  if (!request.auth) {
    throw new Error('unauthenticated');
  }

  const { industry, contentType, goal, tone, language } = request.data;
  if (!industry || !contentType || !goal) {
    throw new Error('invalid-argument');
  }

  const content = `[Generated Content for ${industry} (${contentType})]\n\nTone: ${tone}\nLanguage: ${language}\n\nPost Body:\n"Hey everyone! Check out our new gym 'sportage' in Egypt..."\n\n#Gym #Egypt #Sportage #Fitness`;

  return { content, status: 'success' };
});

/**
 * CRON SCHEDULER (Runs every 1 minute)
 * Replaces Google Cloud Tasks to avoid billing.
 * Scans all 'scheduled_posts' subcollections for pending content.
 */
exports.checkScheduledPosts = onSchedule("every 1 minutes", async (event) => {
  const now = admin.firestore.Timestamp.now();
  console.log(`Cron started at: ${now.toDate().toISOString()}`);

  // Query all 'scheduled_posts' subcollections across all companies
  const query = admin.firestore()
    .collectionGroup('scheduled_posts')
    .where('status', '==', 'pending')
    .where('scheduledFor', '<=', now)
    .orderBy('scheduledFor', 'asc')
    .limit(20);

  const snapshot = await query.get();

  if (snapshot.empty) {
    console.log('No pending posts to publish.');
    return;
  }

  console.log(`Found ${snapshot.size} posts to process.`);

  const results = await Promise.all(snapshot.docs.map(async (doc) => {
    const postData = doc.data();
    const postRef = doc.ref;

    console.log(`Processing post ${doc.id}: ${postData.content.substring(0, 30)}...`);

    try {
      // Simulate Social Platform API Calls (Meta, TikTok, etc.)
      // In Phase 5, this will use the company's access tokens.
      
      await postRef.update({
        status: 'published',
        publishedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Successfully published post ${doc.id}`);
      return { id: doc.id, status: 'success' };
    } catch (error) {
      console.error(`Failed to publish post ${doc.id}:`, error);
      await postRef.update({ 
        status: 'failed', 
        error: error.message 
      });
      return { id: doc.id, status: 'error', message: error.message };
    }
  }));

  console.log(`Cron finished. Processed ${results.length} posts.`);
});
