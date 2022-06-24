// main index.js

import { NativeModules, Dimensions } from "react-native";
import { Platform, NativeEventEmitter } from "react-native";
const { width } = Dimensions.get("window");

const { TxLogin } = NativeModules;

const emitter = new NativeEventEmitter(Platform.OS === "ios" ? TxLogin : null);

const carrierMap = {
  0: "",
  1: "mobile",
  2: "unicom",
  3: "telecom",
};

export default class TxAuthSdk {
  static listener = null;
  static async init(apiId) {
    return TxLogin.init(apiId);
  }
  static async login(params) {
    if (params.login_width && Platform.OS === "android") {
      params.login_margin_left = Math.ceil((width - params.login_width) / 2);
    }
    return TxLogin.login(params);
  }
  static addListener(callbacks) {
    this.listener = emitter.addListener("TxAuthSdk", (data) => {
      if (!data) return;
      if (data.type === "TokenSuccess" && Platform.OS === "ios") {
        data.carrier = carrierMap[data.carrier];
      }
      if (callbacks[data.type]) {
        callbacks[data.type](data);
      }
    });
  }
  static removeListener() {
    this.listener?.remove();
  }
}
