/**
 * @format
 */

import {AppRegistry, Platform} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
import TxAuthSdk from '@byron-react-native/tx-login';

TxAuthSdk.init(Platform.OS === 'ios' ? '1400696411' : '1400685703');

AppRegistry.registerComponent(appName, () => App);
