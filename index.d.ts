declare module "@byron-react-native/tx-login" {
  export interface TxAuthSdkUiModel {
    background_color: string;
    background_image: string;
    /**
     * 导航栏返回图标路径
     */
    nav_icon: string;
    /**
     * 导航栏标题
     */
    nav_title: string;
    nav_title_size: number;
    nav_title_color: string;
    /**
     * logo图片路径
     */
    image_logo: string;
    state_text_size: number;
    state_text_color: string;
    /**
     * 其他登录方式文字
     */
    other_text: string;
    other_text_size: number;
    other_text_color: string;
    /**
     * 号码
     */
    number_size: number;
    number_color: string;
    number_offset_y: number;
    /**
     * 登录按钮
     */
    login_text: string;
    login_text_size: number;
    login_text_color: string;
    login_text_bold: boolean;
    login_image: string;
    login_width: number;
    login_height: number;
    login_offset_y: number;
    /**
     * 隐私协议
     */
    protocol_y: number;
    protocol_text_size: number;
    protocol_text_color: string;
    protocol_highlight_color: string;
    /**
     * 隐私协议页面
     */
    view_background_color: string;
    view_text_color: string;
    view_text_size: number;
    view_back_icon: string;
  }
  /**
   * @carrier mobile 中国移动
   * @carrier unicom 中国联通
   * @carrier telecom 中国电信
   */
  export type ITxAuthSdkCarrier = "mobile" | "unicom" | "telecom";
  export interface TxAuthSdkCb {
    /**
     * 点击一键登录按钮
     */
    LoginClick: () => void;
    /**
     * 一键登录结束
     */
    LoginComplete: () => void;
    /**
     * 未同意协议回调函数
     */
    NotAgreement: () => void;
    /**
     * 获取 token 失败
     */
    TokenFailure: (data: { error: string }) => void;
    /**
     * 获取 token 成功
     * @carrier mobile 中国移动
     * @carrier unicom 中国联通
     * @carrier telecom 中国电信
     */
    TokenSuccess: (data: { token: string; carrier: ITxAuthSdkCarrier }) => void;
    /**
     * 返回按钮点击回调
     */
    BackPressed: () => void;
    /**
     * 使用其他方式登录回调
     */
    OtherLogin: () => void;
  }

  export default class TxAuthSdk {
    static init(apiId: string): Promise<void>;
    static login(params: Partial<TxAuthSdkUiModel>): Promise<void>;
    static addListener(callbacks?: Partial<TxAuthSdkCb>): void;
    static removeListener(): void;
  }
}
