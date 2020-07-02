library visiart.globals;

//API
//const String API_BASE_URL = "http://91.121.165.149";
const String API_BASE_URL = "https://www.visiart.fr";

const String API_TOKEN_KEY = "token";
const String API_USER_ID_KEY = "userId";

const String API_REGISTER = API_BASE_URL + "/auth/local/register";
const String API_LOGIN = API_BASE_URL + "/auth/local";
const String API_USERS_ME = API_BASE_URL + "/users/me";
const String API_USERS = API_BASE_URL + "/users";
const String API_HOBBIES = API_BASE_URL + "/hobbies";
const String API_EVENT = API_BASE_URL + "/events";
const String API_EVENT_LANG = API_BASE_URL + "/events?_limit=50&language=";
const String API_EVENT_CAROUSEL = API_BASE_URL + "/events?_limit=20&language=";
const String API_EVENT_FAVORITE = API_BASE_URL + "/events?favorite_eq=true&language=";
const String API_EVENT_RECENT = API_BASE_URL + "/events?_sort=startDate:ASC&language=";

const API_HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Awards
bool curiousBadgeEnabled = false;
bool investedBadgeEnabled = false;
bool reagentBadgeEnabled = false;
bool passionateBadgeEnabled = false;
int counterCurious = 0;
int counterInvested = 0;
int counterReagent = 0;
int counterPassionate = 0;
int finalCounterCurious = 1;
int finalCounterInvested = 5;
int finalCounterReagent = 8;
int counterDrawing = 3;
int finalCounterPassionate = 6;
