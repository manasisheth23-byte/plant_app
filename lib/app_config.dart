 class AppConfig{
static String app_name = 'Flutter ERP';

static String default_language = "en";

static const bool HTTPS = true;
// Local
// static const DOMAIN_PATH = "10.0.0.223:8392";

// http://125.99.42.184:8211/ERPAPI/api/    //for Testing Sales Order Document type
// static const DOMAIN_PATH = "125.99.42.184:8211";

// http://125.99.42.182:8392/ERPAPI/api/    //for Testing Approval Screen
// static const DOMAIN_PATH = "125.99.42.182:8392";
  //static const DOMAIN_PATH = "10.0.0.245:8211";



// Public
// static const DOMAIN_PATH = "125.99.42.184:8211";
//static const DOMAIN_PATH = "125.99.42.182:8432";
//static const DOMAIN_PATH = "125.99.42.182:8442";
  // static const DOMAIN_PATH = "10.0.0.223:8432";
 //  static const DOMAIN_PATH = "10.0.0.223:8442";
//static const DOMAIN_PATH = "125.99.42.184:8611";
//static const DOMAIN_PATH = "10.0.0.245:8517";
 //static const DOMAIN_PATH = "10.0.0.223:8563";
 //static const DOMAIN_PATH = "10.0.0.245:8217";
  //static const DOMAIN_PATH = "103.135.8.50:777";
    //static const DOMAIN_PATH = "192.168.1.251:8033";



 //static const DOMAIN_PATH = "125.99.42.182:8563";
//static const DOMAIN_PATH = "10.0.0.245:8517";
 // static const DOMAIN_PATH = "10.0.0.223:8563";

//static const DOMAIN_PATH = "125.99.42.184:8517";
 //static const DOMAIN_PATH = "10.0.0.245:8230";
//static const DOMAIN_PATH = "10.0.0.223:8431";
//static const DOMAIN_PATH = "125.99.42.182:8431";
//static const DOMAIN_PATH = "10.0.0.223:8431";
//static const DOMAIN_PATH = "125.99.42.182:8431";
//static const DOMAIN_PATH = "103.135.8.50:777";
//static const DOMAIN_PATH = "192.168.1.251:8033";
 // static const DOMAIN_PATH = "125.99.42.184:8230";

 // static const DOMAIN_PATH = "125.99.42.184:8517";

//static const DOMAIN_PATH = "10.0.0.245:8611";
//static const DOMAIN_PATH = "10.0.0.223:8432";
//static const DOMAIN_PATH = "erp.cloud9ebiz.com";
//static const DOMAIN_PATH = "10.0.0.245:8217";
//static const DOMAIN_PATH = "10.0.0.245:8217";

   //static const DOMAIN_PATH = "c9businesssuite.cloud9ebiz.com";
  // static const DOMAIN_PATH = "125.99.42.182:8532";
   // static const DOMAIN_PATH = "10.0.0.223:8532";


   //static const DOMAIN_PATH = "10.0.0.223:8565";
   // https://c9erpitek.cloud9ebiz.com/
   // static const DOMAIN_PATH = "c9erpitek.cloud9ebiz.com";
    static const DOMAIN_PATH = "erp.itekrfid.com";

//static const DOMAIN_PATH = "10.0.0.223:8565";
//static const DOMAIN_PATH = "125.99.42.184:8217";




//do not configure these below
static const String API_ENDPATH = "ERPAPI/api/";
static const String PROTOCOL = HTTPS ? "https://" : "http://";
static const String RAW_BASE_URL = "http://${DOMAIN_PATH}";
static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";
//"${RAW_BASE_URL}/${API_ENDPATH}";
}
