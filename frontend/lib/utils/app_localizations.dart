/// Comprehensive multi-language localization dictionary for AgroSentinel AI.
/// Supports English, Hindi (हिंदी), Marathi (मराठी), and Kannada (ಕನ್ನಡ).
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    // ── Navigation Tabs ──────────────────────────────────────────────────
    'nav_home': {
      'English': 'Home',
      'Hindi': 'होम',
      'Marathi': 'मुख्यपृष्ठ',
      'Kannada': 'ಮುಖಪುಟ',
    },
    'nav_scan': {
      'English': 'Scan',
      'Hindi': 'स्कैन',
      'Marathi': 'स्कॅन',
      'Kannada': 'ಸ್ಕ್ಯಾನ್',
    },
    'nav_analytics': {
      'English': 'Analytics',
      'Hindi': 'एनालिटिक्स',
      'Marathi': 'अ‍ॅनालिटिक्स',
      'Kannada': 'ವಿಶ್ಲೇಷಣೆ',
    },
    'nav_alerts': {
      'English': 'Alerts',
      'Hindi': 'अलर्ट्स',
      'Marathi': 'इशारे',
      'Kannada': 'ಎಚ್ಚರಿಕೆಗಳು',
    },

    // ── Home Dashboard ───────────────────────────────────────────────────
    'good_morning': {
      'English': 'Good morning,',
      'Hindi': 'शुभ प्रभात,',
      'Marathi': 'शुभ प्रभात,',
      'Kannada': 'ಶುಭೋದಯ,',
    },
    'good_afternoon': {
      'English': 'Good afternoon,',
      'Hindi': 'शुभ दोपहर,',
      'Marathi': 'शुभ दुपार,',
      'Kannada': 'ಶುಭ ಮಧ್ಯಾಹ್ನ,',
    },
    'good_evening': {
      'English': 'Good evening,',
      'Hindi': 'शुभ संध्या,',
      'Marathi': 'शुभ संध्याकाळ,',
      'Kannada': 'ಶುಭ ಸಂಜೆ,',
    },
    'hero_subtitle': {
      'English': 'Peak sunlight — ideal time for field diagnostics.',
      'Hindi': 'तेज धूप — खेत में पत्तों की जांच के लिए सबसे सही समय।',
      'Marathi': 'तीव्र सूर्यप्रकाश — शेतातील रोगांच्या निदानासाठी उत्तम वेळ.',
      'Kannada': 'ಉತ್ತಮ ಸೂರ್ಯನ ಬೆಳಕು — ಬೆಳೆ ರೋಗ ಪತ್ತೆಹಚ್ಚಲು ಸೂಕ್ತ ಸಮಯ.',
    },
    'drone_active': {
      'English': 'AI SURVEILLANCE DRONE ACTIVE',
      'Hindi': 'एआई ड्रोन निगरानी सक्रिय',
      'Marathi': 'एआय ड्रोन देखरेख सुरू आहे',
      'Kannada': 'ಎಐ ಕಣ್ಗಾವಲು ಡ್ರೋನ್ ಸಕ್ರಿಯವಾಗಿದೆ',
    },
    'field_health': {
      'English': 'Field Health',
      'Hindi': 'खेत का स्वास्थ्य',
      'Marathi': 'शेताचे आरोग्य',
      'Kannada': 'ಹೊಲದ ಆರೋಗ್ಯ',
    },
    'seven_day_health': {
      'English': '7-Day Field Health',
      'Hindi': '7-दिवसीय खेत स्वास्थ्य',
      'Marathi': '7-दिवसीय शेताचे आरोग्य',
      'Kannada': '7-ದಿನಗಳ ಬೆಳೆ ಆರೋಗ್ಯ',
    },
    'scans_today': {
      'English': 'Scans Today',
      'Hindi': 'आज के स्कैन',
      'Marathi': 'आजचे स्कॅन्स',
      'Kannada': 'ಇಂದಿನ ಸ್ಕ್ಯಾನ್‌ಗಳು',
    },
    'active_alerts': {
      'English': 'Active Alerts',
      'Hindi': 'सक्रिय अलर्ट',
      'Marathi': 'सक्रिय इशारे',
      'Kannada': 'ಸಕ್ರಿಯ ಎಚ್ಚರಿಕೆಗಳು',
    },
    'diseases_detected': {
      'English': 'Diseases Detected',
      'Hindi': 'पहचाने गए रोग',
      'Marathi': 'आढळलेले रोग',
      'Kannada': 'ಪತ್ತೆಯಾದ ರೋಗಗಳು',
    },
    'treatments_active': {
      'English': 'Treatments Active',
      'Hindi': 'सक्रिय उपचार',
      'Marathi': 'सक्रिय उपचार',
      'Kannada': 'ಸಕ್ರಿಯ ಚಿಕಿತ್ಸೆಗಳು',
    },
    'auto_pathology': {
      'English': 'Automated Leaf Pathology',
      'Hindi': 'स्वचालित पत्ती रोग निदान',
      'Marathi': 'स्वयंचलित पान रोग निदान',
      'Kannada': 'ಸ್ವಯಂಚಾಲಿತ ಎಲೆ ರೋಗಶಾಸ್ತ್ರ',
    },
    'auto_pathology_sub': {
      'English': 'Grad-CAM heatmap · Instant Rx',
      'Hindi': 'थर्मल हीटमैप · त्वरित उपचार',
      'Marathi': 'थर्मल हीटमॅप · त्वरित उपचार',
      'Kannada': 'ಉಷ್ಣ ನಕ್ಷೆ · ತ್ವರಿತ ಚಿಕಿತ್ಸೆ',
    },
    'try_demo': {
      'English': 'Try Demo',
      'Hindi': 'डेमो देखें',
      'Marathi': 'डेमो पहा',
      'Kannada': 'ಡೆಮೊ ನೋಡಿ',
    },
    'quick_demo': {
      'English': 'Quick Diagnosis Demo',
      'Hindi': 'त्वरित नमूना परीक्षण',
      'Marathi': 'त्वरित नमुना चाचणी',
      'Kannada': 'ತ್ವರಿತ ರೋಗನಿರ್ಣಯ ಪರೀಕ್ಷೆ',
    },
    'analyse_leaf': {
      'English': 'Analyse a Leaf',
      'Hindi': 'पत्ती का विश्लेषण करें',
      'Marathi': 'पानाचे विश्लेषण करा',
      'Kannada': 'ಎಲೆಯನ್ನು ವಿಶ್ಲೇಷಿಸಿ',
    },
    'recent_scans': {
      'English': 'Recent Scans & Surveillance',
      'Hindi': 'हाल के स्कैन और निगरानी',
      'Marathi': 'अलीकडील स्कॅन्स आणि देखरेख',
      'Kannada': 'ಇತ್ತೀಚಿನ ಸ್ಕ್ಯಾನ್‌ಗಳು ಮತ್ತು ಕಣ್ಗಾವಲು',
    },
    'live_badge': {
      'English': 'Live',
      'Hindi': 'लाइव',
      'Marathi': 'थेट',
      'Kannada': 'ಲೈವ್',
    },

    // ── Weather & Sensors ────────────────────────────────────────────────
    'sunny': {
      'English': 'Sunny',
      'Hindi': 'धूप',
      'Marathi': 'ऊन',
      'Kannada': 'ಬಿಸಿಲು',
    },
    'humidity': {
      'English': 'Humidity',
      'Hindi': 'नमी',
      'Marathi': 'आर्द्रता',
      'Kannada': 'ಆರ್ದ್ರತೆ',
    },
    'wind': {
      'English': 'Wind',
      'Hindi': 'हवा',
      'Marathi': 'वारा',
      'Kannada': 'ಗಾಳಿ',
    },
    'moisture': {
      'English': 'Moisture',
      'Hindi': 'मिट्टी की नमी',
      'Marathi': 'मातीचा ओलावा',
      'Kannada': 'ಮಣ್ಣಿನ ತೇವಾಂಶ',
    },

    // ── Scan Screen ──────────────────────────────────────────────────────
    'scan_title': {
      'English': 'Scan a Leaf',
      'Hindi': 'पत्ती स्कैन करें',
      'Marathi': 'पान स्कॅन करा',
      'Kannada': 'ಎಲೆ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
    },
    'camera_ready': {
      'English': 'Ready for Leaf Photography',
      'Hindi': 'पत्ती की तस्वीर लेने के लिए तैयार',
      'Marathi': 'पानाचा फोटो काढण्यासाठी तयार',
      'Kannada': 'ಎಲೆಯ ಫೋಟೋ ತೆಗೆಯಲು ಸಿದ್ಧ',
    },
    'camera_sub': {
      'English': 'Open camera or upload gallery photo below',
      'Hindi': 'कैमरा खोलें या गैलरी से फोटो चुनें',
      'Marathi': 'कॅमेरा उघडा किंवा गॅलरीतून फोटो निवडा',
      'Kannada': 'ಕ್ಯಾಮರಾ ತೆರೆಯಿರಿ ಅಥವಾ ಗ್ಯಾಲರಿಯಿಂದ ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ',
    },
    'camera': {
      'English': 'Camera',
      'Hindi': 'कैमरा',
      'Marathi': 'कॅमेरा',
      'Kannada': 'ಕ್ಯಾಮರಾ',
    },
    'gallery': {
      'English': 'Gallery',
      'Hindi': 'गैलरी',
      'Marathi': 'गॅलरी',
      'Kannada': 'ಗ್ಯಾಲರಿ',
    },
    'field_area_label': {
      'English': 'Field area (acres)',
      'Hindi': 'खेत का क्षेत्रफल (एकड़)',
      'Marathi': 'शेताचे क्षेत्रफळ (एकर)',
      'Kannada': 'ಹೊಲದ ವಿಸ್ತೀರ್ಣ (ಎಕರೆ)',
    },
    'analyse': {
      'English': 'Analyse',
      'Hindi': 'विश्लेषण करें',
      'Marathi': 'विश्लेषण करा',
      'Kannada': 'ವಿಶ್ಲೇಷಿಸಿ',
    },
    'analysing': {
      'English': 'Analysing…',
      'Hindi': 'विश्लेषण हो रहा है…',
      'Marathi': 'विश्लेषण सुरू आहे…',
      'Kannada': 'ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ…',
    },
    'take_photo_hint': {
      'English': 'Take or upload a clear photo of the leaf first.',
      'Hindi': 'कृपया पहले पत्ती की एक साफ तस्वीर लें या अपलोड करें।',
      'Marathi': 'कृपया आधी पानाचा स्पष्ट फोटो काढा किंवा अपलोड करा.',
      'Kannada': 'ದಯವಿಟ್ಟು ಮೊದಲು ಎಲೆಯ ಸ್ಪಷ್ಟ ಫೋಟೋ ತೆಗೆಯಿರಿ ಅಥವಾ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.',
    },

    // ── Result & Treatment Screen ────────────────────────────────────────
    'detection_result': {
      'English': 'Detection Result',
      'Hindi': 'जांच का परिणाम',
      'Marathi': 'तपासणीचा निकाल',
      'Kannada': 'ಪತ್ತೆ ಫಲಿತಾಂಶ',
    },
    'confidence': {
      'English': 'Confidence',
      'Hindi': 'सटीकता (विश्वास)',
      'Marathi': 'अचूकता (विश्वास)',
      'Kannada': 'ವಿಶ್ವಾಸಾರ್ಹತೆ',
    },
    'infected_area': {
      'English': 'Infected Area',
      'Hindi': 'प्रभावित क्षेत्र',
      'Marathi': 'बाधित क्षेत्र',
      'Kannada': 'ಸೋಂಕಿತ ಪ್ರದೇಶ',
    },
    'gradcam_heatmap': {
      'English': 'Grad-CAM Heatmap',
      'Hindi': 'थर्मल हीटमैप विश्लेषण',
      'Marathi': 'थर्मल हीटमॅप विश्लेषण',
      'Kannada': 'ಉಷ್ಣ ನಕ್ಷೆ ವಿಶ್ಲೇಷಣೆ',
    },
    'gradcam_sub': {
      'English': 'Thermal focus on necrotic lesion hotspots',
      'Hindi': 'रोगग्रस्त घावों और धब्बों पर थर्मल ध्यान',
      'Marathi': 'रोगट भागांवर आणि डागांवर थर्मल लक्ष',
      'Kannada': 'ರೋಗಗ್ರಸ್ತ ಕಲೆಗಳ ಮೇಲೆ ಉಷ್ಣ ಕೇಂದ್ರೀಕರಣ',
    },
    'financial_loss': {
      'English': 'Estimated financial loss',
      'Hindi': 'अनुमानित वित्तीय नुकसान',
      'Marathi': 'अंदाजे आर्थिक नुकसान',
      'Kannada': 'ಅಂದಾಜು ಆರ್ಥಿಕ ನಷ್ಟ',
    },
    'projected_yield_loss': {
      'English': 'projected yield loss',
      'Hindi': 'अनुमानित उपज हानि',
      'Marathi': 'अंदाजे पीक नुकसान',
      'Kannada': 'ಅಂದಾಜು ಇಳುವರಿ ನಷ್ಟ',
    },
    'top3_predictions': {
      'English': 'Top 3 predictions',
      'Hindi': 'शीर्ष 3 भविष्यवाणियां',
      'Marathi': 'शीर्ष 3 अंदाज',
      'Kannada': 'ಟಾಪ್ 3 ಮುನ್ಸೂಚನೆಗಳು',
    },
    'view_treatment_plan': {
      'English': 'View Treatment Plan',
      'Hindi': 'उपचार योजना देखें',
      'Marathi': 'उपचार योजना पहा',
      'Kannada': 'ಚಿಕಿತ್ಸಾ ಯೋಜನೆಯನ್ನು ವೀಕ್ಷಿಸಿ',
    },
    'healthy_crop_msg': {
      'English': 'Crop looks healthy — no treatment needed.',
      'Hindi': 'फसल स्वस्थ दिख रही है — किसी उपचार की आवश्यकता नहीं है।',
      'Marathi': 'पीक निरोगी दिसत आहे — उपचारांची गरज नाही.',
      'Kannada': 'ಬೆಳೆ ಆರೋಗ್ಯಕರವಾಗಿ ಕಾಣುತ್ತದೆ — ಯಾವುದೇ ಚಿಕಿತ್ಸೆ ಅಗತ್ಯವಿಲ್ಲ.',
    },
    'treatment_plan': {
      'English': 'Treatment Plan',
      'Hindi': 'उपचार योजना',
      'Marathi': 'उपचार योजना',
      'Kannada': 'ಚಿಕಿತ್ಸಾ ಯೋಜನೆ',
    },
    'step_by_step_treatment': {
      'English': 'Step-by-step treatment',
      'Hindi': 'चरण-दर-चरण उपचार विधि',
      'Marathi': 'टप्प्याटप्प्याने उपचार पद्धत',
      'Kannada': 'ಹಂತ-ಹಂತದ ಚಿಕಿತ್ಸಾ ವಿಧಾನ',
    },
    'medication': {
      'English': 'Medication',
      'Hindi': 'दवाइयाँ और स्प्रे',
      'Marathi': 'औषधे आणि फवारणी',
      'Kannada': 'ಔಷಧಿಗಳು ಮತ್ತು ಸಿಂಪಡಣೆ',
    },
    'prevention_tips': {
      'English': 'Prevention tips',
      'Hindi': 'रोकथाम के उपाय',
      'Marathi': 'प्रतिबंधात्मक उपाय',
      'Kannada': 'ಮುನ್ನೆಚ್ಚರಿಕೆ ಕ್ರಮಗಳು',
    },
    'outbreak_alert_title': {
      'English': 'OUTBREAK ALERT',
      'Hindi': 'रोग प्रकोप चेतावनी (अलर्ट)',
      'Marathi': 'रोग प्रादुर्भाव इशारा',
      'Kannada': 'ರೋಗ ಹರಡುವಿಕೆಯ ಎಚ್ಚರಿಕೆ',
    },
    'fl_network_title': {
      'English': 'Federated Learning Network',
      'Hindi': 'सुरक्षित एआई नेटवर्क (फ़ेडरेटेड लर्निंग)',
      'Marathi': 'सुरक्षित एआय नेटवर्क (फेडरेटेड लर्निंग)',
      'Kannada': 'ಸುರಕ್ಷಿತ ಎಐ ನೆಟ್‌ವರ್ಕ್ (ಫೆಡರೇಟೆಡ್ ಲರ್ನಿಂಗ್)',
    },
    'fl_network_desc': {
      'English': 'This detection helped improve the shared model without your photos ever leaving your device.',
      'Hindi': 'आपकी तस्वीरें आपके डिवाइस से बाहर जाए बिना, इस जांच ने पूरे नेटवर्क के एआई मॉडल को बेहतर बनाने में मदद की।',
      'Marathi': 'तुमचे फोटो तुमच्या फोनमधून बाहेर न जाता, या तपासणीने एआय मॉडेल अधिक सक्षम करण्यास मदत केली.',
      'Kannada': 'ನಿಮ್ಮ ಫೋಟೋಗಳು ಸಾಧನವನ್ನು ಬಿಟ್ಟು ಹೋಗದೆ, ಈ ಪತ್ತೆಯು ಎಐ ಮಾದರಿಯನ್ನು ಸುಧಾರಿಸಲು ಸಹಾಯ ಮಾಡಿದೆ.',
    },
    'node_synced': {
      'English': 'Node active · model synced',
      'Hindi': 'नोड सक्रिय · मॉडल सिंक हुआ',
      'Marathi': 'नोड सक्रिय · मॉडेल सिंक झाले',
      'Kannada': 'ನೋಡ್ ಸಕ್ರಿಯ · ಮಾದರಿ ಸಿಂಕ್ ಆಗಿದೆ',
    },

    // ── Analytics Screen ─────────────────────────────────────────────────
    'analytics_title': {
      'English': 'Analytics & History',
      'Hindi': 'एनालिटिक्स और इतिहास',
      'Marathi': 'अ‍ॅनालिटिक्स आणि इतिहास',
      'Kannada': 'ವಿಶ್ಲೇಷಣೆ ಮತ್ತು ಇತಿಹಾಸ',
    },
    'total_loss': {
      'English': 'Total financial loss',
      'Hindi': 'कुल वित्तीय नुकसान',
      'Marathi': 'एकूण आर्थिक नुकसान',
      'Kannada': 'ಒಟ್ಟು ಆರ್ಥಿಕ ನಷ್ಟ',
    },
    'total_scans': {
      'English': 'Total scans',
      'Hindi': 'कुल स्कैन',
      'Marathi': 'एकूण स्कॅन्स',
      'Kannada': 'ಒಟ್ಟು ಸ್ಕ್ಯಾನ್‌ಗಳು',
    },
    'filter_label': {
      'English': 'Filter:',
      'Hindi': 'फ़िल्टर:',
      'Marathi': 'फिल्टर:',
      'Kannada': 'ಫಿಲ್ಟರ್:',
    },
    'all_crops': {
      'English': 'All crops',
      'Hindi': 'सभी फसलें',
      'Marathi': 'सर्व पिके',
      'Kannada': 'ಎಲ್ಲಾ ಬೆಳೆಗಳು',
    },
    'disease_frequency': {
      'English': 'Disease frequency',
      'Hindi': 'रोग की आवृत्ति',
      'Marathi': 'रोगांची वारंवारता',
      'Kannada': 'ರೋಗಗಳ ಆವರ್ತನ',
    },
    'past_scans': {
      'English': 'Past scans',
      'Hindi': 'पुराने स्कैन',
      'Marathi': 'मागील स्कॅन्स',
      'Kannada': 'ಹಿಂದಿನ ಸ್ಕ್ಯಾನ್‌ಗಳು',
    },
    'no_past_scans': {
      'English': 'No scans yet — tap Analyse to get started.',
      'Hindi': 'अभी तक कोई स्कैन नहीं — शुरू करने के लिए विश्लेषण पर टैप करें।',
      'Marathi': 'अद्याप कोणतेही स्कॅन्स नाहीत — सुरू करण्यासाठी विश्लेषणावर टॅप करा.',
      'Kannada': 'ಇನ್ನೂ ಯಾವುದೇ ಸ್ಕ್ಯಾನ್‌ಗಳಿಲ್ಲ — ಪ್ರಾರಂಭಿಸಲು ವಿಶ್ಲೇಷಿಸಿ ಮೇಲೆ ಟ್ಯಾಪ್ ಮಾಡಿ.',
    },

    // ── Alerts Screen ────────────────────────────────────────────────────
    'outbreak_alerts': {
      'English': 'Outbreak Alerts',
      'Hindi': 'प्रकोप अलर्ट',
      'Marathi': 'रोग प्रादुर्भाव इशारे',
      'Kannada': 'ರೋಗ ಹರಡುವಿಕೆಯ ಎಚ್ಚರಿಕೆಗಳು',
    },
    'no_alerts': {
      'English': 'No active alerts right now',
      'Hindi': 'फिलहाल कोई सक्रिय अलर्ट नहीं है',
      'Marathi': 'सध्या कोणतेही सक्रिय इशारे नाहीत',
      'Kannada': 'ಪ್ರಸ್ತುತ ಯಾವುದೇ ಸಕ್ರಿಯ ಎಚ್ಚರಿಕೆಗಳಿಲ್ಲ',
    },
    'radar_desc': {
      'English': 'Your area is monitored continuously by the AgroSentinel radar mesh. Crops look clear.',
      'Hindi': 'एग्रोसेंटिनल नेटवर्क द्वारा आपके क्षेत्र की निरंतर निगरानी की जा रही है। फसलें सुरक्षित हैं।',
      'Marathi': 'अ‍ॅग्रोसेंटिनेल नेटवर्कद्वारे तुमच्या परिसरावर सतत लक्ष ठेवले जात आहे. पिके सुरक्षित आहेत.',
      'Kannada': 'ಆಗ್ರೊಸೆಂಟಿನೆಲ್ ಜಾಲವು ನಿಮ್ಮ ಪ್ರದೇಶವನ್ನು ನಿರಂತರವಾಗಿ ಮೇಲ್ವಿಚಾರಣೆ ಮಾಡುತ್ತಿದೆ. ಬೆಳೆಗಳು ಸುರಕ್ಷಿತವಾಗಿವೆ.',
    },
    'detected_in_area': {
      'English': 'Detected in your area',
      'Hindi': 'आपके क्षेत्र में पाया गया',
      'Marathi': 'तुमच्या परिसरात आढळला',
      'Kannada': 'ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಪತ್ತೆಯಾಗಿದೆ',
    },
    'impact': {
      'English': 'impact',
      'Hindi': 'प्रभावित',
      'Marathi': 'नुकसान',
      'Kannada': 'ಪರಿಣಾಮ',
    },

    // ── Settings Screen ──────────────────────────────────────────────────
    'settings_title': {
      'English': 'Settings & Profile',
      'Hindi': 'सेटिंग्स और प्रोफ़ाइल',
      'Marathi': 'सेटिंग्ज आणि प्रोफाईल',
      'Kannada': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಮತ್ತು ಪ್ರೊಫೈಲ್',
    },
    'farmer_profile': {
      'English': 'Farmer Profile',
      'Hindi': 'किसान प्रोफ़ाइल',
      'Marathi': 'शेतकरी प्रोफाईल',
      'Kannada': 'ರೈತರ ಪ್ರೊಫೈಲ್',
    },
    'farmer_name': {
      'English': 'Farmer Name',
      'Hindi': 'किसान का नाम',
      'Marathi': 'शेतकऱ्याचे नाव',
      'Kannada': 'ರೈತರ ಹೆಸರು',
    },
    'field_area_section': {
      'English': 'Your Field Area',
      'Hindi': 'आपका खेत का क्षेत्रफल',
      'Marathi': 'तुमचे शेताचे क्षेत्रफळ',
      'Kannada': 'ನಿಮ್ಮ ಹೊಲದ ವಿಸ್ತೀರ್ಣ',
    },
    'field_area_desc': {
      'English': 'Enter or choose the total cultivable area of your farm. This is used to project crop yield and calculate potential financial loss accurately.',
      'Hindi': 'अपने खेत का कुल क्षेत्रफल दर्ज करें या चुनें। इसका उपयोग फसल उपज और संभावित वित्तीय नुकसान की सटीक गणना के लिए किया जाता है।',
      'Marathi': 'तुमच्या शेताचे एकूण क्षेत्रफळ प्रविष्ट करा किंवा निवडा. पीक उत्पादन आणि संभाव्य नुकसानाची अचूक गणना करण्यासाठी याचा वापर केला जातो.',
      'Kannada': 'ನಿಮ್ಮ ಜಮೀನಿನ ಒಟ್ಟು ವಿಸ್ತೀರ್ಣವನ್ನು ನಮೂದಿಸಿ ಅಥವಾ ಆಯ್ಕೆಮಾಡಿ. ಬೆಳೆ ಇಳುವರಿ ಮತ್ತು ಸಂಭವನೀಯ ನಷ್ಟವನ್ನು ಲೆಕ್ಕಹಾಕಲು ಇದನ್ನು ಬಳಸಲಾಗುತ್ತದೆ.',
    },
    'total_field_area': {
      'English': 'Total Field Area',
      'Hindi': 'कुल खेत का क्षेत्रफल',
      'Marathi': 'एकूण शेताचे क्षेत्रफळ',
      'Kannada': 'ಒಟ್ಟು ಹೊಲದ ವಿಸ್ತೀರ್ಣ',
    },
    'preferred_language': {
      'English': 'Preferred Language',
      'Hindi': 'पसंदीदा भाषा',
      'Marathi': 'पसंतीची भाषा',
      'Kannada': 'ಆದ್ಯತೆಯ ಭಾಷೆ',
    },
    'save_settings': {
      'English': 'Save Settings',
      'Hindi': 'सेटिंग्स सहेजें',
      'Marathi': 'सेटिंग्ज जतन करा',
      'Kannada': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಿ',
    },
    'settings_saved': {
      'English': 'Profile & Field Settings Saved',
      'Hindi': 'प्रोफ़ाइल और खेत सेटिंग्स सहेजी गईं',
      'Marathi': 'प्रोफाईल आणि शेताच्या सेटिंग्ज जतन केल्या',
      'Kannada': 'ಪ್ರೊಫೈಲ್ ಮತ್ತು ಹೊಲದ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ',
    },
    'acre': {
      'English': 'acre',
      'Hindi': 'एकड़',
      'Marathi': 'एकर',
      'Kannada': 'ಎಕರೆ',
    },
    'acres': {
      'English': 'acres',
      'Hindi': 'एकड़',
      'Marathi': 'एकर',
      'Kannada': 'ಎಕರೆ',
    },
  };

  // ── Crops Dictionary ─────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _cropTranslations = {
    'Rice': {
      'English': 'Rice',
      'Hindi': 'चावल (धान)',
      'Marathi': 'भात (तांदूळ)',
      'Kannada': 'ಭತ್ತ (ಅಕ್ಕಿ)',
    },
    'Tomato': {
      'English': 'Tomato',
      'Hindi': 'टमाटर',
      'Marathi': 'टोमॅटो',
      'Kannada': 'ಟೊಮೇಟೊ',
    },
    'Potato': {
      'English': 'Potato',
      'Hindi': 'आलू',
      'Marathi': 'बटाटा',
      'Kannada': 'ಆಲೂಗಡ್ಡೆ',
    },
    'Corn (Maize)': {
      'English': 'Corn (Maize)',
      'Hindi': 'मक्का (भुट्टा)',
      'Marathi': 'मका',
      'Kannada': 'ಮೆಕ್ಕೆಜೋಳ',
    },
    'Grape': {
      'English': 'Grape',
      'Hindi': 'अंगूर',
      'Marathi': 'द्राक्ष',
      'Kannada': 'ದ್ರಾಕ್ಷಿ',
    },
    'Cotton': {
      'English': 'Cotton',
      'Hindi': 'कपास',
      'Marathi': 'कापूस',
      'Kannada': 'ಹತ್ತಿ',
    },
    'Wheat': {
      'English': 'Wheat',
      'Hindi': 'गेहूं',
      'Marathi': 'गहू',
      'Kannada': 'ಗೋಧಿ',
    },
    'Sugarcane': {
      'English': 'Sugarcane',
      'Hindi': 'गन्ना',
      'Marathi': 'ऊस',
      'Kannada': 'ಕಬ್ಬು',
    },
  };

  // ── Diseases Dictionary ──────────────────────────────────────────────
  static const Map<String, Map<String, String>> _diseaseTranslations = {
    'Brown Spot': {
      'English': 'Brown Spot',
      'Hindi': 'भूरा धब्बा रोग (Brown Spot)',
      'Marathi': 'तपकिरी ठिपके रोग (Brown Spot)',
      'Kannada': 'ಕಂದು ಚುಕ್ಕೆ ರೋಗ (Brown Spot)',
    },
    'Late Blight': {
      'English': 'Late Blight',
      'Hindi': 'पछेती झुलसा (Late Blight)',
      'Marathi': 'उशिरा येणारा करपा (Late Blight)',
      'Kannada': 'ತಡವಾಗಿ ಬರುವ ರೋಗ (Late Blight)',
    },
    'Early Blight': {
      'English': 'Early Blight',
      'Hindi': 'अगेती झुलसा (Early Blight)',
      'Marathi': 'लवकर येणारा करपा (Early Blight)',
      'Kannada': 'ಆರಂಭಿಕ ರೋಗ (Early Blight)',
    },
    'Common Rust': {
      'English': 'Common Rust',
      'Hindi': 'रतुआ / गेरूई रोग (Common Rust)',
      'Marathi': 'तांबेरा रोग (Common Rust)',
      'Kannada': 'ತುಕ್ಕು ರೋಗ (Common Rust)',
    },
    'Bacterial Leaf Blight': {
      'English': 'Bacterial Leaf Blight',
      'Hindi': 'जीवाणु पत्ती झुलसा (Bacterial Blight)',
      'Marathi': 'जिवाणूजन्य पानांचा करपा (Bacterial Blight)',
      'Kannada': 'ಬ್ಯಾಕ್ಟೀರಿಯಾದ ಎಲೆ ರೋಗ (Bacterial Blight)',
    },
    'Leaf Mold': {
      'English': 'Leaf Mold',
      'Hindi': 'पत्ती फफूंद (Leaf Mold)',
      'Marathi': 'पानांवरील बुरशी (Leaf Mold)',
      'Kannada': 'ಎಲೆ ಬೂಷ್ಟು (Leaf Mold)',
    },
    'Healthy': {
      'English': 'Healthy',
      'Hindi': 'स्वस्थ फसल',
      'Marathi': 'निरोगी पीक',
      'Kannada': 'ಆರೋಗ್ಯಕರ ಬೆಳೆ',
    },
    'Diseased': {
      'English': 'Diseased',
      'Hindi': 'रोगग्रस्त',
      'Marathi': 'बाधित',
      'Kannada': 'ರೋಗಗ್ರಸ್ತ',
    },
  };

  // ── Long Text & Treatment Sentences Dictionary ───────────────────────
  static const Map<String, Map<String, String>> _phraseTranslations = {
    'Remove and destroy infected leaves immediately': {
      'English': 'Remove and destroy infected leaves immediately',
      'Hindi': 'संक्रमित पत्तियों को तुरंत हटाकर नष्ट कर दें',
      'Marathi': 'संसर्ग झालेली पाने त्वरित काढून नष्ट करा',
      'Kannada': 'ಸೋಂಕಿತ ಎಲೆಗಳನ್ನು ತಕ್ಷಣ ತೆಗೆದು ನಾಶಮಾಡಿ',
    },
    'Improve field drainage to reduce moisture buildup': {
      'English': 'Improve field drainage to reduce moisture buildup',
      'Hindi': 'नमी कम करने के लिए खेत में जल निकासी में सुधार करें',
      'Marathi': 'जास्त ओलावा कमी करण्यासाठी शेतातील पाण्याचा निचरा सुधारा',
      'Kannada': 'ಹೆಚ್ಚಿನ ತೇವಾಂಶ ಕಡಿಮೆ ಮಾಡಲು ಹೊಲದಲ್ಲಿ ನೀರು ಹರಿದುಹೋಗುವಂತೆ ಮಾಡಿ',
    },
    'Apply recommended fungicide within 48 hours': {
      'English': 'Apply recommended fungicide within 48 hours',
      'Hindi': '48 घंटों के भीतर अनुशंसित कवकनाशी (फंगीसाइड) का छिड़काव करें',
      'Marathi': '४८ तासांच्या आत शिफारस केलेले बुरशीनाशक फवारा',
      'Kannada': '48 ಗಂಟೆಗಳ ಒಳಗೆ ಶಿಫಾರಸು ಮಾಡಿದ ಶಿಲೀಂಧ್ರನಾಶಕವನ್ನು ಸಿಂಪಡಿಸಿ',
    },
    'Re-inspect the field after 7 days': {
      'English': 'Re-inspect the field after 7 days',
      'Hindi': '7 दिनों के बाद खेत का पुनः निरीक्षण करें',
      'Marathi': '७ दिवसांनंतर शेताची पुन्हा पाहणी करा',
      'Kannada': '7 ದಿನಗಳ ನಂತರ ಹೊಲವನ್ನು ಮರು-ಪರಿಶೀಲಿಸಿ',
    },
    'Mancozeb 75% WP - 2.5g/litre water': {
      'English': 'Mancozeb 75% WP - 2.5g/litre water',
      'Hindi': 'मैंकोजेब 75% WP - 2.5 ग्राम/लीटर पानी',
      'Marathi': 'मॅनकोझेब ७५% WP - २.५ ग्रॅम/लिटर पाणी',
      'Kannada': 'ಮ್ಯಾಂಕೋಜೆಬ್ 75% WP - 2.5 ಗ್ರಾಂ/ಲೀಟರ್ ನೀರು',
    },
    'Propiconazole 25% EC - 1ml/litre water': {
      'English': 'Propiconazole 25% EC - 1ml/litre water',
      'Hindi': 'प्रोपिकोनाज़ोल 25% EC - 1 मिली/लीटर पानी',
      'Marathi': 'प्रोपिकोनाझोल २५% EC - १ मिली/लिटर पाणी',
      'Kannada': 'ಪ್ರೊಪಿಕೊನಜೋಲ್ 25% EC - 1 ಮಿಲಿ/ಲೀಟರ್ ನೀರು',
    },
    'Use certified disease-free seeds': {
      'English': 'Use certified disease-free seeds',
      'Hindi': 'प्रमाणित रोगमुक्त बीजों का ही उपयोग करें',
      'Marathi': 'प्रमाणित रोगमुक्त बियाण्यांचा वापर करा',
      'Kannada': 'ಪ್ರಮಾಣೀಕೃತ ರೋಗಮುಕ್ತ ಬೀಜಗಳನ್ನು ಬಳಸಿ',
    },
    'Avoid excess nitrogen fertilizer': {
      'English': 'Avoid excess nitrogen fertilizer',
      'Hindi': 'अत्यधिक नाइट्रोजन उर्वरक (यूरिया) के प्रयोग से बचें',
      'Marathi': 'जास्त नायट्रोजन खतांचा (युरिया) वापर टाळा',
      'Kannada': 'ಹೆಚ್ಚುವರಿ ಸಾರಜನಕ ಗೊಬ್ಬರವನ್ನು ತಪ್ಪಿಸಿ',
    },
    'Maintain proper plant spacing for airflow': {
      'English': 'Maintain proper plant spacing for airflow',
      'Hindi': 'हवा के संचार के लिए पौधों के बीच उचित दूरी बनाए रखें',
      'Marathi': 'हवा खेळती राहण्यासाठी रोपांमध्ये योग्य अंतर ठेवा',
      'Kannada': 'ಗಾಳಿಯಾಡಲು ಸಸ್ಯಗಳ ನಡುವೆ ಸರಿಯಾದ ಅಂತರವನ್ನು ಕಾಪಾಡಿಕೊಳ್ಳಿ',
    },
    'Continue current watering schedule': {
      'English': 'Continue current watering schedule',
      'Hindi': 'वर्तमान पानी देने की समय सारिणी जारी रखें',
      'Marathi': 'सध्याचे पाणी देण्याचे वेळापत्रक चालू ठेवा',
      'Kannada': 'ಪ್ರಸ್ತುತ ನೀರಾವರಿ ವೇಳಾಪಟ್ಟಿಯನ್ನು ಮುಂದುವರಿಸಿ',
    },
    'Monitor weekly for early signs of stress': {
      'English': 'Monitor weekly for early signs of stress',
      'Hindi': 'शुरुआती तनाव के लक्षणों के लिए साप्ताहिक निगरानी करें',
      'Marathi': 'पिकांच्या आरोग्यावर दर आठवड्याला लक्ष ठेवा',
      'Kannada': 'ಆರೋಗ್ಯದ ಆರಂಭಿಕ ಲಕ್ಷಣಗಳಿಗಾಗಿ ವಾರಕ್ಕೊಮ್ಮೆ ಗಮನಿಸಿ',
    },
    'Brown Spot detected in 6 nearby fields this week. Regional outbreak risk is elevated.': {
      'English': 'Brown Spot detected in 6 nearby fields this week. Regional outbreak risk is elevated.',
      'Hindi': 'इस सप्ताह 6 नजदीकी खेतों में भूरा धब्बा रोग पाया गया है। क्षेत्रीय प्रकोप का खतरा बढ़ गया है।',
      'Marathi': 'या आठवड्यात जवळच्या ६ शेतांमध्ये तपकिरी ठिपके रोग आढळला आहे. प्रादुर्भावाचा धोका वाढला आहे.',
      'Kannada': 'ಈ ವಾರ ಹತ್ತಿರದ 6 ಹೊಲಗಳಲ್ಲಿ ಕಂದು ಚುಕ್ಕೆ ರೋಗ ಕಂಡುಬಂದಿದೆ. ರೋಗ ಹರಡುವ ಅಪಾಯ ಹೆಚ್ಚಾಗಿದೆ.',
    },
  };

  /// Get localized UI string for [key] based on [language].
  static String get(String key, String language) {
    final entry = _localizedValues[key];
    if (entry == null) return key;
    return entry[language] ?? entry['English'] ?? key;
  }

  /// Translate a crop name (e.g. 'Rice' -> 'चावल (धान)')
  static String crop(String cropName, String language) {
    final entry = _cropTranslations[cropName];
    if (entry == null) return cropName;
    return entry[language] ?? entry['English'] ?? cropName;
  }

  /// Translate a disease name (e.g. 'Brown Spot' -> 'भूरा धब्बा रोग')
  static String disease(String diseaseName, String language) {
    final entry = _diseaseTranslations[diseaseName];
    if (entry == null) return diseaseName;
    return entry[language] ?? entry['English'] ?? diseaseName;
  }

  /// Translate phrases, treatments, and messages
  static String phrase(String phraseText, String language) {
    final entry = _phraseTranslations[phraseText];
    if (entry == null) return phraseText;
    return entry[language] ?? entry['English'] ?? phraseText;
  }
}
