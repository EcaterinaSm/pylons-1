import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pylons_wallet/services/third_party_services/crashlytics_helper.dart';
import 'package:pylons_wallet/utils/base_env.dart';
import 'package:pylons_wallet/utils/constants.dart';

abstract class RemoteConfigService {
  /// This method initialize the remote config
  Future init();

  /// This method returns the base environment
  /// Output: [BaseEnv] the base env of the blockchain
  BaseEnv getBaseEnv();

  /// This method returns the android app version in the remote config
  String getAndroidAppVersion();

  /// This method returns the ios app version in the remote config
  String getIOSAppVersion();

  /// This method returns whether the app is in maintenance mode or not
  bool getMaintenanceMode();
}

class RemoteConfigServiceImpl implements RemoteConfigService {
  FirebaseRemoteConfig firebaseRemoteConfig;
  CrashlyticsHelper crashlyticsHelper;

  static String grpcUrl = "GRPC_URL";
  static String lcdUrl = "LCD_URL";
  static String lcdPort = "LCD_PORT";
  static String grpcPort = "GRPC_PORT";

  static String ethUrl = "ETH_URL";
  static String tendermintPort = "TENDERMINT_PORT";
  static String faucetUrl = "FAUCET_URL";
  static String wsUrl = "WS_URL";
  static String stripeUrl = "STRIPE_SERVER";
  static String stripePubKey = "STRIPE_PUB_KEY";
  static String stripeTestEnv = "STRIPE_TEST_ENV";
  static String stripeCallbackUrl = "STRIPE_CALLBACK_URL";
  static String stripeCallbackRefreshUrl = "STRIPE_CALLBACK_REFRESH_URL";
  static String androidVersion = "ANDROID_VERSION";
  static String iosVERSION = "IOS_VERSION";
  static String chainId = "CHAIN_ID";
  static String ibcTrace = "IBC_TRACE_URL";
  static String mongoUrl = "MONGO_URL";
  static String skus = "skus";

  static String maintenanceMode = "MAINTENANCE_MODE";

  RemoteConfigServiceImpl(
      {required this.firebaseRemoteConfig,
      required this.crashlyticsHelper});

  @override
  BaseEnv getBaseEnv() {
    return BaseEnv()
      ..setEnv(
        lcdUrl: firebaseRemoteConfig.getString(lcdUrl),
        grpcUrl: firebaseRemoteConfig.getString(grpcUrl),
        lcdPort: firebaseRemoteConfig.getString(lcdPort),
        mongoUrl: firebaseRemoteConfig.getString(mongoUrl),
        grpcPort: firebaseRemoteConfig.getString(grpcPort),
        ethUrl: firebaseRemoteConfig.getString(ethUrl),
        faucetUrl: firebaseRemoteConfig.getString(faucetUrl),
        stripeUrl: firebaseRemoteConfig.getString(stripeUrl),
        stripePubKey: firebaseRemoteConfig.getString(stripePubKey),
        stripeTestEnv: firebaseRemoteConfig.getString(stripeTestEnv) == 'true',
        stripeCallbackUrl: firebaseRemoteConfig.getString(stripeCallbackUrl),
        stripeCallbackRefreshUrl:
            firebaseRemoteConfig.getString(stripeCallbackRefreshUrl),
        chainId: firebaseRemoteConfig.getString(chainId),
        ibcTraceUrl: firebaseRemoteConfig.getString(ibcTrace),
        skus: firebaseRemoteConfig.getString(skus),
      );
  }

  @override
  Future init() async {
    await firebaseRemoteConfig.setDefaults({
      lcdUrl: dotenv.env['LCD_URL'],
      grpcUrl: dotenv.env['GRPC_URL'],
      lcdPort: dotenv.env['LCD_PORT'],
      grpcPort: dotenv.env['GRPC_PORT'],
      ethUrl: dotenv.env['ETH_URL'],
      tendermintPort: dotenv.env['TENDERMINT_PORT'],
      faucetUrl: dotenv.env['FAUCET_URL'],
      wsUrl: dotenv.env['WS_URL'],
      stripeUrl: dotenv.env['STRIPE_SERVER'],
      stripePubKey: dotenv.env['STRIPE_PUB_KEY'],
      stripeTestEnv: dotenv.env['STRIPE_TEST_ENV'] == 'true',
      stripeCallbackUrl: dotenv.env['STRIPE_CALLBACK_URL'] ?? "",
      stripeCallbackRefreshUrl: dotenv.env['STRIPE_CALLBACK_REFRESH_URL'] ?? "",
      iosVERSION: IOS_VERSION,
      androidVersion: ANDROID_VERSION,
      chainId: dotenv.env['CHAIN_ID'],
      skus: defaultPylonsSKUs,
      mongoUrl: dotenv.env[mongoUrl] ?? "",
      maintenanceMode: false,
    });

    firebaseRemoteConfig.setConfigSettings(RemoteConfigSettings(
      minimumFetchInterval: const Duration(minutes: 5),
      fetchTimeout: const Duration(seconds: 10),
    ));

    try {
      await firebaseRemoteConfig.fetchAndActivate();
    } on FormatException catch (_) {
      /// Happens when there is no internet on first launch.
      crashlyticsHelper.recordFatalError(error: _.message);
    } on FirebaseException catch(_){
      crashlyticsHelper.recordFatalError(error: _.message ?? "");
    }
  }

  @override
  String getAndroidAppVersion() {
    return firebaseRemoteConfig.getString(androidVersion);
  }

  @override
  String getIOSAppVersion() {
    return firebaseRemoteConfig.getString(iosVERSION);
  }

  @override
  bool getMaintenanceMode() {
    return firebaseRemoteConfig.getBool(maintenanceMode);
  }
}
