/* eslint-disable max-len */
import {getMessaging} from "firebase-admin/messaging";
import {https} from "firebase-functions/v2";

export const notifySingleUser = https.onRequest(async (req, res) => {
  const body = req.body;
  const userId = body.userFcmId;
  const titleText = body.title;
  const bodyText = body.description;

  const message = {
    notification: {
      title: titleText,
      body: bodyText,
    },
    token: userId,
  };

  console.log("notifySingleUser message is", message);

  await getMessaging().send(message).then((response) => {
    console.log("notifySingleUser response is", response);
    res.send({success: true, resp: response});
  })
      .catch((error) => {
        console.log("notifySingleUser error is", error);
        res.send({success: false, error: error});
      });
});

export const notifyUserGroup = https.onRequest(async (req, res) => {
  const body = req.body;
  const userList = body.userList;
  const titleText = body.title;
  const bodyText = body.description;

  if (!Array.isArray(userList) || userList.length === 0) {
    return res.status(400).send({success: false, error: "Invalid userList"});
  }

  const message = {
    notification: {
      title: titleText,
      body: bodyText,
    },
    tokens: userList,
  };

  console.log("notifyUserGroup message is", message);

  await getMessaging().sendEachForMulticast(message).then((response) => {
    console.log("notifyUserGroup response is", response);
    res.send({success: true, resp: response});
  })
      .catch((error) => {
        console.log("notifyUserGroup error is", error);
        res.send({success: false, error: error});
      });
});
