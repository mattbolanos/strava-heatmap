interface Env {
  STRAVA_CLIENT_ID: string;
  STRAVA_CLIENT_SECRET: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname !== "/auth/token") {
      return new Response("Not Found", { status: 404 });
    }

    if (request.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    let body: Record<string, unknown>;
    try {
      body = await request.json();
    } catch {
      return new Response("Invalid JSON", { status: 400 });
    }

    const grantType = body.grant_type;
    if (grantType !== "authorization_code" && grantType !== "refresh_token") {
      return new Response("Invalid grant_type", { status: 400 });
    }

    const stravaPayload: Record<string, unknown> = {
      client_id: env.STRAVA_CLIENT_ID,
      client_secret: env.STRAVA_CLIENT_SECRET,
      grant_type: grantType,
    };

    if (grantType === "authorization_code") {
      stravaPayload.code = body.code;
    } else {
      stravaPayload.refresh_token = body.refresh_token;
    }

    const stravaResponse = await fetch("https://www.strava.com/oauth/token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(stravaPayload),
    });

    return new Response(stravaResponse.body, {
      status: stravaResponse.status,
      headers: { "Content-Type": "application/json" },
    });
  },
};
