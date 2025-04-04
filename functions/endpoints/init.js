import {setGlobalOptions} from "firebase-functions/v2";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import dotenv from "dotenv";

dotenv.config();

setGlobalOptions({region: "europe-west1", enforceAppCheck: true});

initializeApp();

const db = getFirestore();

export {db};
