/* eslint-disable max-len */
import {https} from "firebase-functions/v2";
import {db} from "./init.js";

export const getKeys = https.onRequest(async (req, res) => {
  try {
    const docRef = db.collection("keys").doc("keys");
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).send({success: false, error: "Document not found"});
    }

    return res.send({success: true, data: doc.data()});
  } catch (err) {
    console.log("Error retrieving function URLs:", err);
    return res.status(500).send({success: false, error: "Internal Server Error"});
  }
});
