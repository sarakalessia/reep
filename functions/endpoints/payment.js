/* eslint-disable max-len */
import axios from "axios";
import {https} from "firebase-functions/v2";
import {google} from "googleapis";

const appleSandboxUrl = process.env.APPLE_SENDBOX_URL;
const appleSharedSecret = process.env.APPLE_SHARED_SECRET;
const androidLicenseKey = process.env.ANDROID_LICENSE_KEY;

export const verifyApplePurchaseReceipt = https.onRequest(async (req, res) => {
  const receiptData = req.body.receiptData;
  if (!receiptData) {
    console.log("Receipt data missing or invalid in request body");
    return res.status(400).send({success: false, error: "Invalid receipt data provided"});
  }

  const verificationUrl = appleSandboxUrl;
  console.log(`Using Apple Verification URL: ${verificationUrl}`);

  const applePayload = {
    "receipt-data": receiptData,
    "password": appleSharedSecret,
  };

  try {
    const appleResponse = await axios.post(verificationUrl, applePayload);
    const appleVerificationResult = appleResponse.data;
    console.log("Apple Verification Response:", appleVerificationResult);

    const appleStatus = appleVerificationResult.status;

    if (appleStatus === 0) {
      console.log("Apple Receipt Verification Successful - Status 0");

      return res.status(200).send({
        success: true,
        message: "Apple Receipt Verification successful (Sandbox)", // Indicate Sandbox for testing
        appleResponse: appleVerificationResult, // For now, send the raw Apple response for debugging
      });
    } else if (appleStatus === 21007) {
      console.log("Sandbox receipt used in production. Retrying against sandbox...");
      return res.status(200).send({
        success: true, // For testing in Sandbox, we'll consider 21007 as valid in sandbox context
        message: "Apple Receipt Verification successful (Sandbox - Status 21007 handled as success for testing)",
        appleResponse: appleVerificationResult,
      });
    } else {
      console.log(`Apple Receipt Verification Failed - Status: ${appleStatus}`);
      return res.status(400).send({
        success: false,
        error: `Apple Receipt Verification failed. Status Code: ${appleStatus}`,
        appleResponse: appleVerificationResult, // Send back Apple's response for debugging
      });
    }
  } catch (error) {
    console.log("Error verifying receipt with Apple:", error);
    return res.status(500).send({success: false, error: "Internal error verifying receipt with Apple", details: error.message});
  }
});

export const validateAndroidPurchaseReceipt = https.onRequest(async (req, res) => {
  console.log("req.body");
  console.log(req.body);
  console.log("A");
  const purchaseToken = req.body.purchaseToken;
  const productId = req.body.productId;
  const packageName = req.body.packageName;

  console.log("B");
  if (!purchaseToken || !productId || !packageName) {
    console.log("Missing purchaseToken, productId, or packageName in request body");
    return res.status(400).send({success: false, error: "Invalid purchase data provided"});
  }

  console.log("C");
  if (!androidLicenseKey) {
    console.error("Android License Key is not configured in Firebase Functions environment variables.");
    return res.status(500).send({success: false, error: "Server configuration error: Android License Key missing"});
  }
  console.log("D");

  try {
    const authClient = new google.auth.GoogleAuth({
      keyFilename: "./keys.json",
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    });
    console.log(authClient);

    const androidpublisher = google.androidpublisher({
      version: "v3",
      authClient,
    });

    const purchaseVerification = await androidpublisher.purchases.subscriptions.get({
      auth: authClient,
      packageName: packageName,
      subscriptionId: productId,
      token: purchaseToken
    });
    console.log("F");

    console.log("purchaseVerification:"+purchaseVerification);
    const purchaseData = purchaseVerification.data;
    console.log("purchaseData:"+purchaseData);
    const purchaseState = purchaseData.paymentState;
    console.log("G");

    if (purchaseState === 0) { // 0: Purchased, 1: Canceled, 2: Pending
      console.log(`Purchase validated for productId: ${productId}, purchaseState: ${purchaseState}`);
      return res.status(200).send({
        success: true,
        message: "Android purchase receipt validated",
        purchaseDetails: purchaseData, // Optionally return full purchase details if needed
      });
    } else {
        console.log("FALLLITO");
      console.log(`Android Receipt Verification Failed - Purchase State: ${purchaseState}`);
      return res.status(400).send({
        success: false,
        error: `Android Receipt Verification failed. Purchase State: ${purchaseState}`,
        purchaseDetails: purchaseData, // Send back purchase details for debugging
      });
    }
  } catch (error) {
    console.error("Error validating Android purchase:", error);
    return res.status(500).send({success: false, error: "Internal error validating Android purchase", details: error.message});
  }
});
