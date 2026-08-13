const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const SYSTEM = `You are LifeTrack's AI coach — a warm, insightful advisor with visibility into three areas of the user's life:
1. Habits — daily completion streaks and consistency patterns
2. Journal & Mood — emotional trends and recent reflections
3. Budget — income, expenses, and spending by category

Your role is to connect these dots and give holistic, personalized advice. When you notice patterns (e.g. low mood on high-spending days, or skipped habits correlating with stress), point them out. Be specific with numbers from the data. Keep responses to 2-4 paragraphs. Use markdown formatting. Be encouraging and honest.`;

exports.handler = async (event) => {
  // Lambda Function URL uses requestContext.http.method (payload v2.0)
  // API Gateway uses event.httpMethod (payload v1.0)
  const method = event.requestContext?.http?.method || event.httpMethod || 'POST';
  const origin = event.headers?.origin || event.headers?.Origin || '*';

  const corsHeaders = {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (method === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  if (method !== 'POST') {
    return { statusCode: 405, headers: corsHeaders, body: JSON.stringify({ error: 'Method Not Allowed' }) };
  }

  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ error: 'Invalid JSON' }) };
  }

  const { type, context: lifeData, question, history = [] } = body;

  if (!type || !lifeData) {
    return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ error: 'Missing fields' }) };
  }

  try {
    let userMessage;

    if (type === 'insights') {
      userMessage = `Please analyze my life data from the past week and give me a holistic weekly summary. Look for connections between my habits, mood, and spending. Highlight wins, patterns, and one specific focus area for next week.\n\n${lifeData}`;
    } else if (type === 'chat') {
      userMessage = `Here is my life data:\n\n${lifeData}\n\nMy question: ${question}`;
    } else {
      return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ error: 'Invalid type' }) };
    }

    const messages = [
      ...history.map((m) => ({ role: m.role, content: m.content })),
      { role: 'user', content: userMessage },
    ];

    const response = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 1024,
      system: SYSTEM,
      messages,
    });

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ content: response.content[0].text }),
    };
  } catch (err) {
    console.error('Claude error:', err);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ error: 'AI request failed' }),
    };
  }
};
