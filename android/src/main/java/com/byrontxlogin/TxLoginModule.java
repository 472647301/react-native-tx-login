// TxLoginModule.java

package com.byrontxlogin;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.rich.oauth.callback.InitCallback;
import com.rich.oauth.callback.PreLoginCallback;
import com.rich.oauth.callback.TokenCallback;
import com.rich.oauth.core.RichAuth;
import com.rich.oauth.core.UIConfigBuild;

import org.json.JSONObject;

public class TxLoginModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;
    private DeviceEventManagerModule.RCTDeviceEventEmitter eventEmitter;

    public TxLoginModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return "TxLogin";
    }

    @ReactMethod
    public void init(String apiId, Promise promise) {
        eventEmitter = reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
        RichAuth.getInstance().init(getReactApplicationContext(), apiId, new InitCallback() {
            @Override
            public void onInitSuccess() {
                promise.resolve(null);
            }

            @Override
            public void onInitFailure(String s) {
                promise.reject("404", s);
            }
        }, 10000L);
    }

    @ReactMethod
    public void login(ReadableMap params, Promise promise) {
        RichAuth.getInstance().preLogin(getCurrentActivity(), new PreLoginCallback() {
            @Override
            public void onPreLoginSuccess() {
                new Thread(){
                    @Override
                    public void run() {
                        super.run();
                        getToken(params);
                    }
                }.start();
                promise.resolve(null);
            }

            @Override
            public void onPreLoginFailure(String s) {
                promise.reject("404", s);
            }
        });
    }

    private View getContentView(ReadableMap params) {
        RelativeLayout relativeLayout = new RelativeLayout(reactContext);
        relativeLayout.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        RelativeLayout inflate = (RelativeLayout) LayoutInflater.from(reactContext).inflate(R.layout.oauth_view, relativeLayout, false);

        if (params.hasKey("background_color")) {
            inflate.setBackgroundColor(Color.parseColor(params.getString("background_color")));
        }
        if (params.hasKey("background_image")) {
            inflate.setBackgroundResource(getDrawableId(params.getString("background_image")));
        }

        // ?????????????????????????????????
        ImageView IvReturn = inflate.findViewById(R.id.cmcc_ouath_navi_return);
        if (params.hasKey("nav_icon")) {
            IvReturn.setImageResource(getDrawableId(params.getString("nav_icon")));
        }
        IvReturn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                WritableMap data = Arguments.createMap();
                data.putString("type", "BackPressed");
                eventEmitter.emit("TxAuthSdk", data);
                RichAuth.getInstance().closeOauthPage();
            }
        });

        TextView IvTitle = inflate.findViewById(R.id.cmcc_ouath_navi_title);
        if (params.hasKey("nav_title")) {
            IvTitle.setText(params.getString("nav_title"));
        }
        if (params.hasKey("nav_title_size")) {
            IvTitle.setTextSize(params.getInt("nav_title_size"));
        }
        if (params.hasKey("nav_title_color")) {
            IvTitle.setTextColor(Color.parseColor(params.getString("nav_title_color")));
        }

        ImageView IvLogo = inflate.findViewById(R.id.cmcc_ouath_image_logo);
        if (params.hasKey("image_logo")) {
            IvLogo.setImageResource(getDrawableId(params.getString("image_logo")));
        }

        // ??????
        TextView cmcc_ouath_state_text = inflate.findViewById(R.id.cmcc_ouath_state_text);
        if (params.hasKey("state_text_size")) {
            cmcc_ouath_state_text.setTextSize(params.getInt("state_text_size"));
        }
        if (params.hasKey("state_text_color")) {
            cmcc_ouath_state_text.setTextColor(Color.parseColor(params.getString("state_text_color")));
        }
        //0.?????? 1.???????????? 2.?????????????????? 3.??????????????????

        switch (RichAuth.getInstance().getOperatorType(reactContext)) {
            case "1":
                cmcc_ouath_state_text.setText("???????????????????????????????????????");
                break;
            case "2":
                cmcc_ouath_state_text.setText("???????????????????????????????????????");
                break;
            case "3":
                cmcc_ouath_state_text.setText("???????????????????????????????????????");
                break;
        }

        TextView tvOtherWay = inflate.findViewById(R.id.cmcc_ouath_other_way);
        if (params.hasKey("other_text")) {
            tvOtherWay.setText(params.getString("other_text"));
        }
        if (params.hasKey("other_text_size")) {
            tvOtherWay.setTextSize(params.getInt("other_text_size"));
        }
        if (params.hasKey("other_text_color")) {
            tvOtherWay.setTextColor(Color.parseColor(params.getString("other_text_color")));
        }
        tvOtherWay.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); // ?????????
        tvOtherWay.getPaint().setAntiAlias(true); // ?????????
        tvOtherWay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                WritableMap data = Arguments.createMap();
                data.putString("type", "OtherLogin");
                eventEmitter.emit("TxAuthSdk", data);
                RichAuth.getInstance().closeOauthPage();
            }
        });
        return inflate;
    }

    private void getToken(ReadableMap params) {

        UIConfigBuild.Builder configBuild = new UIConfigBuild.Builder();

        configBuild.setAuthContentView(getContentView(params));

        // 2???????????????????????????????????????5.0????????????????????????????????????????????????6.0????????????????????????????????????
        configBuild.setStatusBar(Color.TRANSPARENT, true);
        // ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
        configBuild.setFitsSystemWindows(true);

        // 3????????????
        // ???????????????,????????????
        if (params.hasKey("number_size")) {
            configBuild.setNumberSize(params.getInt("number_size"), true);
        }
        if (params.hasKey("number_color")) {
            configBuild.setNumberColor(Color.parseColor(params.getString("number_color")));
        }
        // ??????????????????????????????????????????y??????(setNumFieldOffsetY???setNumFieldOffsetY_B??????????????????????????????)
        if (params.hasKey("number_offset_y")) {
            configBuild.setNumFieldOffsetY(params.getInt("number_offset_y"));
        } else {
            configBuild.setNumFieldOffsetY(80);
        }

        // 4??? ????????????
        // ??????????????????
        if (params.hasKey("login_image")) {
            configBuild.setLoginBtnBg(getDrawableId(params.getString("login_image")));
        }
        // ??????????????????
        if (params.hasKey("login_text")) {
            configBuild.setLoginBtnText(params.getString("login_text"));
        }
        // ??????????????????????????????
        if (params.hasKey("login_text_size")) {
            configBuild.setLoginBtnTextSize(params.getInt("login_text_size"));
        }
        // ????????????????????????
        if (params.hasKey("login_text_color")) {
            configBuild.setLoginBtnTextColor(Color.parseColor(params.getString("login_text_color")));
        }
        // ??????????????????
        if (params.hasKey("login_text_bold")) {
            configBuild.setLoginBtnTextBold(params.getBoolean("login_text_bold"));
        }
        // ?????????????????????dp????????????
        if (params.hasKey("login_width")) {
            configBuild.setLoginBtnWidth(params.getInt("login_width"));
        }
        if (params.hasKey("login_margin_left")) {
            configBuild.setLogBtnMarginLeft(params.getInt("login_margin_left"));
        }
        // ?????????????????????dp????????????
        if (params.hasKey("login_height")) {
            configBuild.setLoginBtnHight(params.getInt("login_height"));
        }
        // ?????????????????????????????????????????????y??????
        if (params.hasKey("login_offset_y")) {
            configBuild.setLogBtnOffsetY(params.getInt("login_offset_y"));
        } else {
            configBuild.setLogBtnOffsetY(380);
        }

        // 5.1???????????????
        // ?????????????????????
        configBuild.setProtocolSelected(false);
        // ?????????????????????+??????????????????????????????????????????????????????
        configBuild.setPrivacyAnimationBoolean(true);
        // ?????????????????????????????????y??????
        if (params.hasKey("protocol_y")) {
            configBuild.setPrivacyOffsetY_B(params.getInt("protocol_y"));
        }
        // ?????????????????????????????????
        if (params.hasKey("protocol_text_size")) {
            configBuild.setPrivacyTextSize(params.getInt("protocol_text_size"));
        }
        // ???????????????????????????????????????
        if (params.hasKey("protocol_text_color") && params.hasKey("protocol_highlight_color")) {
            configBuild.setPrivacyColor(
                    Color.parseColor(params.getString("protocol_highlight_color")),
                    Color.parseColor(params.getString("protocol_text_color"))
                    );
        }
        // ???????????????????????????????????????
        configBuild.setIsGravityCenter(false);
        // ??????????????????????????????????????????0???????????????1?????????
        configBuild.setCheckBoxLocation(0);
        // 5.2?????????????????????????????????
        // ?????????????????????????????????????????????????????????
        if (params.hasKey("view_background_color")) {
            configBuild.setPrivacyNavBgColor(Color.parseColor(params.getString("view_background_color")));
        }
        // ??????????????????????????????????????????????????????
        if (params.hasKey("view_text_color")) {
            configBuild.setPrivacyNavTextColor(Color.parseColor(params.getString("view_text_color")));
        }
        // ??????????????????????????????????????????????????????
        if (params.hasKey("view_text_size")) {
            configBuild.setPrivacyNavTextSize(params.getInt("view_text_size"));
        }
        if (params.hasKey("view_back_icon")) {
            configBuild.setPrivacyNavReturnBackClauseLayoutResID(getDrawableId(params.getString("view_back_icon")));
        }
        // ????????????????????? 0.???????????? 1.???????????? 2.??????
        configBuild.setAppLanguageType(0);

        UIConfigBuild uiConfig = configBuild.build();

        RichAuth.getInstance().login(getReactApplicationContext().getCurrentActivity(), new TokenCallback() {
            @Override
            public void onTokenSuccessResult(String token, String carrier) {
                WritableMap data = Arguments.createMap();
                data.putString("token", token);
                data.putString("carrier", carrier);
                data.putString("type", "TokenSuccess");
                eventEmitter.emit("TxAuthSdk", data);
                RichAuth.getInstance().closeOauthPage();
            }

            @Override
            public void onTokenFailureResult(String error) {
                WritableMap data = Arguments.createMap();
                data.putString("error", error);
                data.putString("type", "TokenFailure");
                eventEmitter.emit("TxAuthSdk", data);
            }

            @Override
            public void onOtherLoginWayResult() {
                WritableMap data = Arguments.createMap();
                data.putString("type", "OtherLogin");
                eventEmitter.emit("TxAuthSdk", data);
            }

            @Override
            public void onBackPressedListener() {
                WritableMap data = Arguments.createMap();
                data.putString("type", "BackPressed");
                eventEmitter.emit("TxAuthSdk", data);
            }

            @Override
            public void onCheckboxChecked(Context context, JSONObject jsonObject) {
                WritableMap data = Arguments.createMap();
                data.putString("type", "NotAgreement");
                eventEmitter.emit("TxAuthSdk", data);
            }

            @Override
            public void onLoginClickComplete(Context context, JSONObject jsonObject) {
                WritableMap data = Arguments.createMap();
                data.putString("type", "LoginComplete");
                RichAuth.getInstance().closeOauthPage();
                eventEmitter.emit("TxAuthSdk", data);
            }

            @Override
            public void onLoginClickStart(Context context, JSONObject jsonObject) {
                WritableMap data = Arguments.createMap();
                data.putString("type", "LoginClick");
                eventEmitter.emit("TxAuthSdk", data);
            }
        }, uiConfig);
    }

    private int getDrawableId(String name) {
        int drawableId = 0;
        Activity av = getReactApplicationContext().getCurrentActivity();
        if (av == null) {
            return drawableId;
        }
        Package pg = av.getClass().getPackage();
        if (pg != null) {
            drawableId = av.getResources().getIdentifier(name, "drawable", pg.getName());
        }
        if (drawableId == 0) {
            drawableId = av.getResources().getIdentifier(name, "drawable", av.getPackageName());
        }
        return drawableId;
    }
}
