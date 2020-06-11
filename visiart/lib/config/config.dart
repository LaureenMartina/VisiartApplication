library visiart.globals;

//API
const String API_BASE_URL = "http://91.121.165.149";

const String API_REGISTER = API_BASE_URL + "/auth/local/register";
const String API_LOGIN = API_BASE_URL + "/auth/local";
const String API_EVENT = API_BASE_URL + "/events";

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