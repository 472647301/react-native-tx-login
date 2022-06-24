# react-native-tx-login

## Getting started

`$ npm install @byron-react-native/tx-login --save`

## Usage
```javascript
import React, {Component} from 'react';
import {StyleSheet, Text, View} from 'react-native';
import {Platform, PermissionsAndroid} from 'react-native';
import TxAuthSdk from '@byron-react-native/tx-login';

/**
 * @param { Promise } promise
 * @param { Object= } errorExt - Additional Information you can pass to the err object
 * @return { Promise }
 */
async function to(promise, errorExt) {
  return promise
    .then(data => [null, data])
    .catch(err => {
      console.log(' >> err:', err);
      if (errorExt) {
        const parsedError = Object.assign({}, err, errorExt);
        return [parsedError, undefined];
      }

      return [err, undefined];
    });
}

export default class App extends Component {
  state = {
    status: 'starting',
    message: '--',
  };

  requestPermission = async () => {
    if (Platform.OS === 'ios') {
      return true;
    }
    const permission = PermissionsAndroid.PERMISSIONS.READ_PHONE_STATE;
    const hasPermission = await PermissionsAndroid.check(permission);
    if (!hasPermission) {
      const status = await PermissionsAndroid.request(permission);
      if (status !== 'granted') {
        Toast.showWithGravity('请开启权限', 2, Toast.CENTER);
        return false;
      }
      return true;
    }
    return true;
  };

  loginTxAuthSdk = async () => {
    await this.requestPermission();
    await to(
      TxAuthSdk.login({
        // background_color: '#ffffff',
        background_image: 'hello',
        nav_icon: 'close',
        nav_title: '本机一键登录',
        nav_title_color: '#ffffff',
        image_logo: 'logo',
        state_text_size: 14,
        state_text_color: '#ffffff',
        other_text: '其他手机号登录',
        other_text_size: 14,
        other_text_color: '#ffffff',
        number_size: 26,
        number_color: '#ffffff',
        login_text: '本机一键登录',
        login_text_size: 14,
        login_text_color: '#ffffff',
        login_image: 'button',
        login_width: 285,
        login_height: 49,
        protocol_text_color: '#ffffff',
        protocol_highlight_color: '#01EADC',
      }),
    );
  };

  onLoginClick = () => {
    console.log(' >> 点击一键登录按钮');
  };

  onLoginComplete = () => {
    console.log(' >> 一键登录结束');
  };

  onNotAgreement = () => {
    console.log(' >> 未同意协议回调函数');
  };

  onTokenFailure = data => {
    console.log(' >> 获取 token 失败: ', data.error);
  };

  onTokenSuccess = data => {
    console.log(' >> 获取 token 成功: ', data.carrier, data.token);
  };

  onBackPressed = () => {
    console.log(' >> 点击返回按钮');
  };

  onOtherLogin = () => {
    console.log(' >> 点击其他登录方式');
  };

  componentDidMount() {
    TxAuthSdk.addListener({
      LoginClick: this.onLoginClick,
      LoginComplete: this.onLoginComplete,
      NotAgreement: this.onNotAgreement,
      TokenFailure: this.onTokenFailure,
      TokenSuccess: this.onTokenSuccess,
      BackPressed: this.onBackPressed,
      OtherLogin: this.onOtherLogin,
    });
  }

  render() {
    return (
      <View style={styles.container}>
        <Text
          style={[styles.welcome, {marginTop: 100}]}
          onPress={this.loginTxAuthSdk}>
          ☆loginTxAuthSdk☆
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
});
```
