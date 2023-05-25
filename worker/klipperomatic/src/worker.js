/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run "npm run dev" in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run "npm run deploy" to publish your worker
*
 * Learn more at https://developers.cloudflare.com/workers/
 */
function buf2hex(buffer) { // buffer is an ArrayBuffer
  return [...new Uint8Array(buffer)]
      .map(x => x.toString(16).padStart(2, '0'))
      .join('');
}

import { AwsClient } from "aws4fetch";


const r2_accountid = "8e6f02b27804f7637bed83636a84428f";
const r2_bucketname = "klipper-o-matic"
const r2_baseurl =  new URL(
  `https://${r2_bucketname}.${r2_accountid}.r2.cloudflarestorage.com`
);

export default {
  async fetch(request, env, ctx) {
    var json_data = await request.json()
    if (!json_data.hasOwnProperty('config')) {
      return new Response("Config not specified", {"status":400})
    }
    var config_data = json_data['config']
    var config_hash = buf2hex(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(config_data)))
    var config_key = "config/" + config_hash.substring(0,2) + "/" + config_hash.substring(2,4) + "/"  + config_hash.substring(5)  +".config"
    var config_obj = await env.KOM_BUCKET.head(config_key)
    if (config_obj === null) {
      config_obj = env.KOM_BUCKET.put(config_key, config_data)
    }

    const r2 = new AwsClient({
      accessKeyId: env.R2_KEY_ID ,
      secretAccessKey: env.R2_SECRET_KEY,
    });

    var config_url = r2_baseurl
    config_url.pathname = config_key

    var config_access_signed = await r2.sign(
      new Request(config_url, {
        method: 'GET'
      }),
      {
        aws: { signQuery: true },
      }
    );
    var config_access_url = config_access_signed.url;

    // Check if we have a build for this version
    if (!json_data.hasOwnProperty('config')) {
      return new Response("Version number not specified", {"status":400})
    }

    var klipper_version = json_data['version']
    if (! klipper_version.match(/^[0-9a-f]{7}$/)) {
      return new Response("Version number not a git shortsha", {"status":400})
    }

    var bundle_key = `builds/${klipper_version}/${config_hash}.tgz`
    var bundle_obj = await env.KOM_BUCKET.head(bundle_key)

    var bundle_url = r2_baseurl
    bundle_url.pathname = bundle_key

    if (bundle_obj === null) {
      var bundle_url_upload = bundle_url
      bundle_url_upload.searchParams.set("X-Amz-Expires", "450");
      var bundle_upload_signed = await r2.sign(
        new Request(bundle_url_upload, {
          method: 'POST'
        }),
        {
          aws: { signQuery: true },
        }
      );
      var bundle_upload_url = bundle_upload_signed.url;
      var gha_req = await fetch("https://api.github.com/repos/Laikulo/Klipper-firmware/actions/workflows/factory-run.yml/dispatches", {
        "method": "POST",
        "headers": {
          "Authorization": `Bearer ${env.GHA_TOKEN}`,
          "User-Agent": "Klipper-O-Matic Worker by aaron@haun.guru/0.0.1"
        },
        "body": JSON.stringify({
          "ref": "main",
          "inputs": {
            "factoryTag": klipper_version,
            "configName": "klipperomatic",
            "configURL": config_access_url,
            "uploadURL": bundle_upload_url
          }
        })
      });
      console.log(await gha_req.text())
      return new Response(`Build not found for that config and version (${config_hash}, ${klipper_version}) It has been statrted, check GHA for status`, {"status": 404, "statusText": "Not Found" })
      // TODO: Make this a JSON response
      // TODO: Store in-progress GHA builds somewhere, (?KV?) to prevent starting multiple, and to allow frontent to repeat for status.
    }


    var bundle_access_signed = await r2.sign(
      new Request(bundle_url, {
        method: 'GET'
      }),
      {
        aws: { signQuery: true },
      }
    );
    var bundle_access_url = bundle_access_signed.url;

    return new Response(JSON.stringify({"bundle": bundle_access_url, "version": klipper_version, "config_hash": config_hash, "success": true, "complete": true}));
  },
};
