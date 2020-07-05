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
const String API_USERS_USERNAME = API_BASE_URL + "/users?username_contains=";
const String API_HOBBIES = API_BASE_URL + "/hobbies";

const String API_DRAWINGS = API_BASE_URL + "/drawings";

const String API_EVENTS = API_BASE_URL + "/events";
const String API_EVENTS_LANG = API_BASE_URL + "/events?_limit=50&language=";
const String API_EVENTS_CAROUSEL = API_BASE_URL + "/events?_limit=20&language=";
const String API_EVENTS_FAVORITE = API_BASE_URL + "/events?favorite_eq=true&language=";
const String API_EVENTS_RECENT = API_BASE_URL + "/events?_sort=startDate:ASC&language=";

const String API_ROOMS = API_BASE_URL + "/rooms";
const String API_ROOMS_MESSAGE = API_BASE_URL + "/room-messages";
const String API_ROOMS_MESSAGE_ID_ROOM = API_BASE_URL + "/room-messages?room=";
const String API_USER_ROOM_PRIVATE = API_BASE_URL + "/user-room-privates";
const String API_ROOMS_NO_PRIVATE_DISPLAY = API_BASE_URL + "/rooms?private=false&display=true";
const String API_USER_ROOM_PRIVATE_FETCH_ROOM_USER = API_BASE_URL + "/user-room-privates?room.display=true&user.id=";

const API_HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Awards
const int COUNTER_CURIOUS = 1;
const int COUNTER_INVESTED = 5;
const int COUNTER_REAGENT = 8;
const int COUNTER_DRAWING = 3;
