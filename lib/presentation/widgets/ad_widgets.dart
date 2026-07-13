import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;
  static int _interstitialCounter = 0;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  // Real AdMob Test IDs (or replacement constants)
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String nativeUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _loadInterstitial();
    } catch (_) {
      _initialized = false;
    }
  }

  // --- Interstitial Ads ---
  static void _loadInterstitial() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static Future<void> trackQuestionView(BuildContext context, {required VoidCallback onComplete}) async {
    _interstitialCounter++;
    if (_interstitialCounter >= 10) {
      _interstitialCounter = 0;
      await showInterstitial(context, onComplete: onComplete);
    } else {
      onComplete();
    }
  }

  static Future<void> showInterstitial(BuildContext context, {required VoidCallback onComplete}) async {
    if (!_initialized || _interstitialAd == null) {
      // Offline / Simulator Fallback
      if (kDebugMode) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop();
              onComplete();
            });
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'AdMob Interstitial Ad (Mockup)\nLoading Next Concept...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        onComplete();
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
        onComplete();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  // --- Rewarded Ads ---
  static void loadRewarded({required VoidCallback onLoaded}) {
    if (!_initialized) return;
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onLoaded();
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static Future<void> showRewarded(
      BuildContext context, {
        required VoidCallback onRewardEarned,
        required VoidCallback onFailed,
      }) async {
    if (!_initialized || _rewardedAd == null) {
      // Mockup simulation
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Unlock Premium Notes'),
            content: const Text(
              'Watch a short sponsored video to unlock this note section for free!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.of(context).pop();
                        onRewardEarned();
                      });
                      return const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Watching Ad (Mockup)...\nReward unlocking in 2 seconds.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Watch Video'),
              ),
            ],
          );
        },
      );
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onFailed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onFailed();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );
    _rewardedAd = null;
  }
}

// --- AdBanner UI Component ---
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService._initialized) {
      _bannerAd = BannerAd(
        adUnitId: AdService.bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _isLoaded = false;
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Interactive Placeholder banner
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ad',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SaiKumarEduTech Ad Space (Offline Safe)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- AdNative UI Component ---
class AdNative extends StatefulWidget {
  const AdNative({super.key});

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService._initialized) {
      _nativeAd = NativeAd(
        adUnitId: AdService.nativeUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _isLoaded = false;
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _nativeAd != null) {
      return Container(
        height: 72,
        alignment: Alignment.center,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    // Native Inline Placeholder
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.ads_click,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Ad',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Learn Java & Crack Interviews!',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try full offline mockups, code references and quizzes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
