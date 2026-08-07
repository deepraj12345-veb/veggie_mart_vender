import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_provider.dart';

const Map<String, Map<String, String>> appTranslations = {
  // Main Nav
  "Orders": {"Hindi": "ऑर्डर्स"},
  "Inventory": {"Hindi": "इन्वेंटरी"},
  "Wallet": {"Hindi": "वॉलेट"},
  "Profile": {"Hindi": "प्रोफ़ाइल"},

  // Profile Screen
  "Profile & Settings": {"Hindi": "प्रोफ़ाइल और सेटिंग्स"},
  "Store Address": {"Hindi": "दुकान का पता"},
  "App Settings": {"Hindi": "ऐप सेटिंग्स"},
  "Language / भाषा": {"Hindi": "भाषा (Language)"},
  "Current: ": {"Hindi": "वर्तमान: "},
  "Help & Support / Contact Admin": {
    "Hindi": "सहायता और समर्थन / एडमिन से संपर्क करें",
  },
  "Logout from Account": {"Hindi": "अकाउंट से लॉगआउट करें"},
  "Cancel": {"Hindi": "रद्द करें"},
  "Logout": {"Hindi": "लॉगआउट"},
  "Are you sure you want to logout from Veg King Vendor app?": {
    "Hindi": "क्या आप Veg King Vendor ऐप से लॉगआउट करना चाहते हैं?",
  },

  // Live Orders
  "Live Orders": {"Hindi": "लाइव ऑर्डर्स"},
  "New": {"Hindi": "नया"},
  "Preparing": {"Hindi": "तैयार हो रहा है"},
  "Ready": {"Hindi": "तैयार है"},
  "Completed": {"Hindi": "पूरा हुआ"},
  "No new incoming orders right now.": {"Hindi": "अभी कोई नया ऑर्डर नहीं है।"},
  "No orders currently being prepared.": {
    "Hindi": "वर्तमान में कोई ऑर्डर तैयार नहीं किया जा रहा है।",
  },
  "No packed orders waiting for pickup.": {
    "Hindi": "कोई भी पैक किया हुआ ऑर्डर पिकअप के लिए इंतज़ार नहीं कर रहा है।",
  },
  "No completed orders yet.": {"Hindi": "अभी तक कोई ऑर्डर पूरा नहीं हुआ है।"},

  // Inventory Screen
  "Catalog & Stock": {"Hindi": "कैटलॉग और स्टॉक"},
  "Search vegetable or fruit name...": {"Hindi": "सब्जी या फल का नाम खोजें..."},
  "No items match your search.": {
    "Hindi": "आपकी खोज से कोई आइटम मेल नहीं खाता।",
  },
  "Add Item": {"Hindi": "आइटम जोड़ें"},

  // Wallet Screen
  "Earnings & Settlements": {"Hindi": "कमाई और सेटलमेंट"},
  "Available Balance": {"Hindi": "उपलब्ध बैलेंस"},
  "Today's Earnings": {"Hindi": "आज की कमाई"},
  "Withdraw Funds": {"Hindi": "पैसे निकालें"},
  "Recent Transactions": {"Hindi": "हाल के लेनदेन"},
  "No transactions found": {"Hindi": "कोई लेनदेन नहीं मिला"},
  "Order": {"Hindi": "ऑर्डर"},
  "Manage Bank Account": {"Hindi": "बैंक खाता प्रबंधित करें"},
  "Withdraw to Bank Account": {"Hindi": "बैंक खाते में पैसे निकालें"},
  "Withdraw to Bank": {"Hindi": "बैंक में पैसे निकालें"},
  "Transfer instant earnings to your registered bank account.": {
    "Hindi": "तुरंत अपनी कमाई को अपने पंजीकृत बैंक खाते में स्थानांतरित करें।",
  },
  "Amount to Withdraw (₹)": {"Hindi": "निकालने की राशि (₹)"},
  "Confirm Transfer": {"Hindi": "स्थानांतरण की पुष्टि करें"},

  // Custom App Bar
  "Store Status": {"Hindi": "स्टोर की स्थिति"},
  "Open (Accepting Orders)": {"Hindi": "खुला (ऑर्डर स्वीकार कर रहे हैं)"},
  "Closed (Not Accepting)": {"Hindi": "बंद (ऑर्डर नहीं ले रहे)"},
  "Online": {"Hindi": "ऑनलाइन"},
  "Offline": {"Hindi": "ऑफ़लाइन"},
  "🟢 Store is now ONLINE for new orders!": {
    "Hindi": "🟢 स्टोर अब नए ऑर्डर्स के लिए ऑनलाइन है!",
  },
  "🔴 Store is OFFLINE. No new orders will arrive.": {
    "Hindi": "🔴 स्टोर ऑफ़लाइन है। कोई नए ऑर्डर नहीं आएंगे।",
  },
};

final translationProvider = Provider<String Function(String)>((ref) {
  final lang = ref.watch(profileProvider).language;
  return (String key) {
    if (lang == "English") return key;
    return appTranslations[key]?[lang] ?? key;
  };
});
