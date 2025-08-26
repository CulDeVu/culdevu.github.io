var r2d = (x) => { return x * 180 / Math.PI; };
var d2r = (x) => { return x * Math.PI / 180; };

var asind = (x) => { return r2d(Math.asin(x)); };
var acos = (x) => { return Math.acos(x); };
var atan2d = (y, x) => { return r2d(Math.atan2(y, x)); };

var cosd = (x) => { return Math.cos(d2r(x)); };
var sind = (x) => { return Math.sin(d2r(x)); };
var tand = (x) => { return Math.tan(d2r(x)); };

var degree_norm = (x) => { return x - 360*Math.floor(x/360); };
var degree_norm_half = (x) => { return (x - 180 - 360*Math.floor((x - 180)/360)) - 180; };
var inside = (x, a, b) => { return (a <= x && x <= b); };

var v3_mul = (a, v) => {
  return [a*v[0], a*v[1], a*v[2]];
};
var v3_length = (v) => {
  return Math.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
};
var v3_norm = (v) => {
  var l = Math.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
  return [v[0]/l, v[1]/l, v[2]/l];
};
var v3_dot = (v1, v2) => {
  return v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
};
var v3_neg = (v) => {
  return [-v[0], -v[1], -v[2]];
};
var v3_add = (a, b) => {
  return [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
};
var v3_sub = (a, b) => {
  return [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
};

var v3_cross = (a, b) => {
  return [
    a[1]*b[2] - a[2]*b[1],
    a[2]*b[0] - a[0]*b[2],
    a[0]*b[1] - a[1]*b[0]];
};
var m3_inv = (m) => {
  // IMPORTANT: we're assuming here that the matrix is always orthonormal!!!
  return [
    [m[0][0], m[1][0], m[2][0]],
    [m[0][1], m[1][1], m[2][1]],
    [m[0][2], m[1][2], m[2][2]]];
};
var mv3_mul = (m, v) => {
  return v3_add(v3_add(
    v3_mul(v[0], m[0]),
    v3_mul(v[1], m[1])),
    v3_mul(v[2], m[2]));
};
var m3_mul = (a, b) => {
  return [
    mv3_mul(a, b[0]),
    mv3_mul(a, b[1]),
    mv3_mul(a, b[2])];
};

// Stolen from the AA+ codebase.
let dt = [
  [ 2447892.50, 56.855270 ], //01 January 1990, UT1-UTC= 0.3287299, Accumulated Leap Seconds=25
  [ 2448257.50, 57.565313 ], //01 January 1991, UT1-UTC= 0.6186873, Accumulated Leap Seconds=26
  [ 2448622.50, 58.309166 ], //01 January 1992, UT1-UTC=-0.1251659, Accumulated Leap Seconds=26
  [ 2448988.50, 59.121841 ], //01 January 1993, UT1-UTC= 0.0621586, Accumulated Leap Seconds=27
  [ 2449353.50, 59.984454 ], //01 January 1994, UT1-UTC= 0.1995463, Accumulated Leap Seconds=28
  [ 2449718.50, 60.785348 ], //01 January 1995, UT1-UTC= 0.3986518, Accumulated Leap Seconds=29
  [ 2450083.50, 61.628659 ], //01 January 1996, UT1-UTC= 0.5553407, Accumulated Leap Seconds=30
  [ 2450449.50, 62.295049 ], //01 January 1997, UT1-UTC=-0.1110486, Accumulated Leap Seconds=30
  [ 2450814.50, 62.965869 ], //01 January 1998, UT1-UTC= 0.2181311, Accumulated Leap Seconds=31
  [ 2451179.50, 63.467337 ], //01 January 1999, UT1-UTC= 0.7166631, Accumulated Leap Seconds=32
  [ 2451544.50, 63.828522 ], //01 January 2000, UT1-UTC= 0.3554779, Accumulated Leap Seconds=32
  [ 2451910.50, 64.090788 ], //01 January 2001, UT1-UTC= 0.0932119, Accumulated Leap Seconds=32
  [ 2452275.50, 64.299804 ], //01 January 2002, UT1-UTC=-0.1158037, Accumulated Leap Seconds=32
  [ 2452640.50, 64.473428 ], //01 January 2003, UT1-UTC=-0.2894276, Accumulated Leap Seconds=32
  [ 2453005.50, 64.573611 ], //01 January 2004, UT1-UTC=-0.3896111, Accumulated Leap Seconds=32
  [ 2453371.50, 64.687631 ], //01 January 2005, UT1-UTC=-0.5036311, Accumulated Leap Seconds=32
  [ 2453736.50, 64.845183 ], //01 January 2006, UT1-UTC= 0.3388174, Accumulated Leap Seconds=33
  [ 2454101.50, 65.146403 ], //01 January 2007, UT1-UTC= 0.0375966, Accumulated Leap Seconds=33
  [ 2454466.50, 65.457349 ], //01 January 2008, UT1-UTC=-0.2733487, Accumulated Leap Seconds=33
  [ 2454832.50, 65.776836 ], //01 January 2009, UT1-UTC= 0.4071638, Accumulated Leap Seconds=34
  [ 2455197.50, 66.069922 ], //01 January 2010, UT1-UTC= 0.1140783, Accumulated Leap Seconds=34
  [ 2455562.50, 66.324557 ], //01 January 2011, UT1-UTC=-0.1405568, Accumulated Leap Seconds=34
  [ 2455927.50, 66.603020 ], //01 January 2012, UT1-UTC=-0.4190198, Accumulated Leap Seconds=34
  [ 2456293.50, 66.906909 ], //01 January 2013, UT1-UTC= 0.2770909, Accumulated Leap Seconds=35
  [ 2456658.50, 67.281038 ], //01 January 2014, UT1-UTC=-0.0970383, Accumulated Leap Seconds=35
  [ 2457023.50, 67.643917 ], //01 January 2015, UT1-UTC=-0.4599167, Accumulated Leap Seconds=35
  [ 2457388.50, 68.102420 ], //01 January 2016, UT1-UTC= 0.0815795, Accumulated Leap Seconds=36
  [ 2457754.50, 68.592718 ], //01 January 2017, UT1-UTC= 0.5912821, Accumulated Leap Seconds=37
  [ 2458119.50, 68.967642 ], //01 January 2018, UT1-UTC= 0.2163577, Accumulated Leap Seconds=37
  [ 2458484.50, 69.220163 ], //01 January 2019, UT1-UTC=-0.0361632, Accumulated Leap Seconds=37
  [ 2458849.50, 69.361155 ], //01 January 2020, UT1-UTC=-0.1771554, Accumulated Leap Seconds=37
  [ 2459215.50, 69.359361 ], //01 January 2021, UT1-UTC=-0.1753606, Accumulated Leap Seconds=37
  [ 2459580.50, 69.294499 ], //01 January 2022, UT1-UTC=-0.1104988, Accumulated Leap Seconds=37
  [ 2459945.50, 69.203868 ], //01 January 2023, UT1-UTC=-0.0198682, Accumulated Leap Seconds=37
  [ 2460310.50, 69.175216 ], //01 January 2024, UT1-UTC= 0.0087837, Accumulated Leap Seconds=37
  [ 2460676.50, 69.137739 ], //01 January 2025, UT1-UTC= 0.0462606, Accumulated Leap Seconds=37
  [ 2461041.50, 69.081490 ], //01 January 2026, UT1-UTC= 0.1025105, Accumulated Leap Seconds=37, Predicted value
  [ 2461406.50, 69.14    ], //2027.00, Predicted value
  [ 2461771.50, 69.34    ], //2028.00, Predicted value
  [ 2462137.50, 69.63    ], //2029.00, Predicted value
  [ 2462502.50, 69.97    ], //2030.00, Predicted value
  [ 2462867.50, 70.32    ], //2031.00, Predicted value
  [ 2463232.50, 70.62    ], //2032.00, Predicted value
  [ 2463598.50, 70.98    ], //2033.00, Predicted value
];

// Dates after October 15 1582 AD (the Gregorian calendar reform) are assumed to be Gregorian calendar dates, and dates before that are assumed to be Julian calendar dates.
let julian_day = (date) => {
  var Y = date.getFullYear();
  var M = date.getMonth() + 1;
  var D = date.getDate() + date.getHours()/24 + date.getMinutes()/1440 + date.getSeconds()/86400 + date.getMilliseconds()/86400000 + date.getTimezoneOffset()/1440;
  if (M == 1 || M == 2) {
    M = M + 12;
    Y = Y - 1;
  }
  var A = Math.floor(Y / 100);
  // [todo: if date is before Oct 15 1582 AD, set B to 0]
  var B = 2 - A + Math.floor(A / 4);
  var JD = Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6 * (M + 1)) + D + B - 1524.5;
  return JD;
};

var dynamical_time = (date) => {
  var JD = julian_day(date);
  
  let DT = dt[date.getFullYear() - 1990][1];
  
  var JDE = JD + DT/86400;
  
  var T = (JDE - 2451545) / 36525;
  return T;
};

mean_sidereal_time = (date) => {
  var T = dynamical_time(date);
  var JD = julian_day(date);
  var sidereal_time = 
      280.46061837 +
      360.98564736629 * (JD - 2451545.0) +
      0.000387933 * T * T +
      -T*T*T / 38710000;
  /*sidereal_time =
    100.46061837 +
    36000.77053608*T +
    0.000387933*T*T +
    -T*T*T / 38710000;*/

  // NOT correct. This is the definition of ERA, which aims to replace APPARENT sidereal time, not MEAN sidereal time!
  // sidereal_time = 360 * (0.779057273 + 1.00273781191135448*(JD - 2451545.0));
  return sidereal_time;
};

// source: Astronomical Almanac for the Year 2017. Washington and Taunton: US Government Printing Office and The UK Hydrographic Office. 2016. ISBN 978-0-7077-41666.
// found on wikipedia: https://en.wikipedia.org/wiki/Sidereal_time on the bit about GMST
// 0.0001 corresponds to roughly 0.02 seconds, or about 1cm
console.assert(inside(
  degree_norm(mean_sidereal_time(new Date("2017-01-01T00:00:00Z"))),
  100.8379, 100.8380));

ecliptic_to_equatorial = (date, x) => {
  var T = dynamical_time(date);
  
  var delta_obliquity = 0;
  
  var obliquity = 
    23.439291 +
    -0.0130042 * T +
    -0.000000164 * T * T +
    0.00000050361 * T * T * T;
  
  var right_ascension = atan2d(sind(x.longitude) * cosd(obliquity) - tand(x.latitude) * sind(obliquity), cosd(x.longitude));
  var declination = asind(sind(x.latitude)*cosd(obliquity) + cosd(x.latitude)*sind(obliquity)*sind(x.longitude));
  
  let ret = {right_ascension: right_ascension, declination: declination, distance: x.distance};
  return ret;
};

equatorial_to_spherical = (date, x) => {
  let sidereal_time = mean_sidereal_time(date);
  return {lat: x.declination, lon: x.right_ascension - sidereal_time, distance: x.distance};
};

let nutation = (date) => {
  var T = dynamical_time(date);
  
  let sun = sun_ellipse(date);
  
  // TODO: take from moon ellipse
  var mean_anomaly_sun =
      357.5291092 +
      35999.0502909 * T +
      -0.0001536 * T*T +
      T*T*T / 24490000;
  var mean_elongation_of_moon = 
      297.8501921 +
      445267.1114034 * T +
      -0.0018819 * T * T +
      T*T*T / 545868 +
      -T*T*T*T / 113065000;
  
  var mean_anomaly_moon =
      134.9633964 +
      477198.8675055 * T +
      0.0087414 * T*T +
      T*T*T / 69699 +
      -T*T*T*T / 14712000;
  // print("mean anomaly of moon: " + degree_norm(mean_anomaly_moon));
  
  // Shit involving moon position
  let L = sun.mean_longitude;
  var L_ = // mean logitude of moon
      218.3164477 +
      481267.88123421 * T +
      -0.0015786*T*T +
      T*T*T / 538841 +
      -T*T*T*T / 65194000;
  var D = mean_elongation_of_moon;
  var M = mean_anomaly_sun;
  var M_ = mean_anomaly_moon;
  var F = // argument_latitude_moon
      93.2720950 +
      483202.0175233 * T +
      -0.0036539*T*T +
      -T*T*T / 3526000 +
      T*T*T*T / 863310000;
  
  // Longitude of the ascending node of the moon's mean orbit
  let longitude_ascending_node =
    125.04452 +
    -1934.136261 * T +
    0.0020708 * T*T +
    T*T*T / 450000;
  let O = longitude_ascending_node;
  
  let delta_longitude =
    0.004777778 * sind(O) +
    0.000366667 * sind(2*L) +
    -0.000063889 * sind(2*L_) +
    0.000058333 * sind(2*O);
  
  let delta_obliquity =
    0.002555556 * cosd(O) +
    0.000158333 * cosd(2*L) +
    0.000027778 * cosd(2*L_) +
    -0.000025 * cosd(2*O);
  
  console.log(delta_longitude);
  console.log(delta_obliquity);
  
  return {delta_longitude: delta_longitude, delta_obliquity: delta_obliquity};
};

let to_equatorial = (date, x) => {
  return ecliptic_to_equatorial(date, x);
};
let to_spherical = (date, x) => {
  return equatorial_to_spherical(date, ecliptic_to_equatorial(date, x));
};

let sun_ellipse = (date) => {
  let T = dynamical_time(date);
  
  let mean_anomaly =
    357.5291092 +
    35999.0502909 * T +
    -0.0001536 * T*T +
    T*T*T / 24490000;
  let argument_of_periapsis =
    -77.0627 +
    1.71954 * T +
    0.0004569 * T * T;
  
  let EOC =
    (1.914602 - 0.004817*T - 0.000014*T*T) * sind(mean_anomaly) +
    (0.019993 - 0.000101*T) * sind(2*mean_anomaly) +
    0.000289 * sind(3*mean_anomaly);
  
  let mean_longitude = mean_anomaly + argument_of_periapsis;
  let true_longitude = mean_longitude + EOC;
  
  let eccentricity = 0.016708634 - 0.000042037 * T - 0.0000001267*T*T
  let true_anomaly = true_longitude - argument_of_periapsis;
  
  return {
    mean_anomaly: mean_anomaly,
    true_anomaly: true_anomaly,
    
    argument_of_periapsis: argument_of_periapsis,
    eccentricity: eccentricity,
    
    mean_longitude: mean_longitude,
    true_longitude: true_longitude,
    
    EOC: EOC,
  };
};
let sun = (date) => {
  let T = dynamical_time(date);
  
  let ellipse = sun_ellipse(date);
  let sun_dist = 149597870.700 * 1.000001018 * (1 - ellipse.eccentricity*ellipse.eccentricity) / (1 + ellipse.eccentricity * cosd(ellipse.true_anomaly));
  
  return {latitude: 0, longitude: ellipse.true_longitude, distance: sun_dist};
};

let moon = (date) => {
  var T = dynamical_time(date);
  
  var mean_anomaly_sun =
      357.5291092 +
      35999.0502909 * T +
      -0.0001536 * T*T +
      T*T*T / 24490000;
  var mean_elongation_of_moon = 
      297.8501921 +
      445267.1114034 * T +
      -0.0018819 * T * T +
      T*T*T / 545868 +
      -T*T*T*T / 113065000;
  
  var mean_anomaly_moon =
      134.9633964 +
      477198.8675055 * T +
      0.0087414 * T*T +
      T*T*T / 69699 +
      -T*T*T*T / 14712000;
  
  // Shit involving moon position
  var L_ = // mean logitude of moon
      218.3164477 +
      481267.88123421 * T +
      -0.0015786*T*T +
      T*T*T / 538841 +
      -T*T*T*T / 65194000;
  var D = mean_elongation_of_moon;
  var M = mean_anomaly_sun;
  var M_ = mean_anomaly_moon;
  var F = // argument_latitude_moon
      93.2720950 +
      483202.0175233 * T +
      -0.0036539*T*T +
      -T*T*T / 3526000 +
      T*T*T*T / 863310000;
  var A1 = 119.75 + 131.849 * T;
  var A2 = 53.09 + 479264.290 * T;
  var A3 = 313.45 + 481266.484 * T;
  var E = 1 - 0.002516*T + 0.0000074*T*T;
  
  var table_47_A = [
    [0, 0, 1, 0, 6288774, -20905355],
    [2, 0, -1, 0, 1274027, -3699111],
    [2, 0, 0, 0, 658314, -2955968],
    [0, 0, 2, 0, 213618, -569925],
    [0, 1, 0, 0, -185116, 48888],
    [0, 0, 0, 2, -144332, -3149],
    [2, 0, -2, 0, 58793, 246158],
    [2, -1, -1, 0, 57066, -152138],
    [2, 0, 1, 0, 53322, -170733],
    [2, -1, 0, 0, 45758, -204586],
    [0, 1, -1, 0, -40923, -129620],
    [1, 0, 0, 0, -34720, 108743],
    [0, 1, 1, 0, -30383, 104755],
    [2, 0, 0, -2, 15327, 10321],
    [0, 0, 1, 2, -12528, 0],
    [0, 0, 1, -2, 10980, 79661],
    [4, 0, -1, 0, 10675, -34782],
    [0, 0, 3, 0, 10034, -23210],
    [4, 0, -2, 0, 8548, -21636],
    [2, 1, -1, 0, -7888, 24208],
    [2, 1, 0, 0, -6766, 30824],
    [1, 0, -1, 0, -5163, -8379],
    [1, 1, 0, 0, 4987, -16675],
    [2, -1, 1, 0, 4036, -12831],
    [2, 0, 2, 0, 3994, -10445],
    [4, 0, 0, 0, 3861, -11650],
    [2, 0, -3, 0, 3665, 14403],
    [0, 1, -2, 0, -2689, -7003],
    [2, 0, -1, 2, -2602, 0],
    [2, -1, -2, 0, 2390, 10056],
    [1, 0, 1, 0, -2348, 6322],
    [2, -2, 0, 0, 2236, -9884],
    // TODO: more terms
    [0, 1, 2, 0, -2120, 5751],
    [0, 2, 0, 0, -2069, 0],
    [2, -2, -1, 0, 2048, -4950],
    [2, 0, 1, -2, -1773, 4130],
    [2, 0, 0, 2, -1595, 0],
    [4, -1, -1, 0, 1215, -3958],
    [0, 0, 2, 2, -1110, 0],
    [3, 0, -1, 0, -892, 3258],
    [2, 1, 1, 0, -810, 2616],
    [4, -1, -2, 0, 759, -1897],
    [0, 2, -1, 0, -713, -2117],
    [2, 2, -1, 0, -700, 2354],
    [2, 1, -2, 0, 691, 0],
    [2, -1, 0, -2, 596, 0],
    [4, 0, 1, 0, 549, -1423],
    [0, 0, 4, 0, 537, -1117],
    [4, -1, 0, 0, 520, -1571],
    [1, 0, -2, 0, -487, -1739],
    [2, 1, 0, -2, -399, 0],
    [0, 0, 2, -2, -381, -4421],
    // TODO: more terms
    [1, 1, 1, 0, 351, 0],
    [3, 0, -2, 0, -340, 0],
    [4, 0, -3, 0, 330, 0],
    [2, -1, 2, 0, 327, 0],
    [0, 2, 1, 0, -323, 1165],
    [1, 1, -1, 0, 299, 0],
    [2, 0, 3, 0, 294, 0],
    [2, 0, -1, -2, 0, 8752]
    ];
  
  var table_47_B_1 = [
    [0, 0, 0, 1, 5128122],
    [0, 0, 1, 1, 280602],
    [0, 0, 1, -1, 277693],
    [2, 0, 0, -1, 173237],
    [2, 0, -1, 1, 55413],
    [2, 0, -1, -1, 46271],
    [2, 0, 0, 1, 32573],
    [0, 0, 2, 1, 17198],
    [2, 0, 1, -1, 9266],
    [0, 0, 2, -1, 8822],
    [2, -1, 0, -1, 8216],
    [2, 0, -2, -1, 4324],
    [2, 0, 1, 1, 4200],
    [2, 1, 0, -1, -3359],
    [2, -1, -1, 1, 2463],
    [2, -1, 0, 1, 2211],
    [2, -1, -1, -1, 2065],
    // TODO: more terms
    [0, 1, -1, -1, -1870],
    [4, 0, -1, -1, 1828],
    [0, 1, 0, 1, -1794],
    [0, 0, 0, 3, -1749],
    [0, 1, -1, 1, -1565],
    [1, 0, 0, 1, -1491],
    [0, 1, 1, 1, -1475],
    [0, 1, 1, -1, -1410],
    [0, 1, 0, -1, -1344],
    [1, 0, 0, -1, -1335],
    [0, 0, 3, 1, 1107],
    [4, 0, 0, -1, 1021],
    [4, 0, -1, 1, 833]
    ];
  var table_47_B_2 = [
    [0, 0, 1, -3, 777],
    [3, 0, -2, 1, 671],
    [2, 0, 0, -3, 607],
    [2, 0, 2, -1, 596],
    [2, -1, 1, -1, 491],
    [2, 0, -2, 1, -451],
    [0, 0, 3, -1, 439],
    [2, 0, 2, 1, 422],
    [2, 0, -3, -1, 421],
    [2, 1, -1, 1, -366],
    [2, 1, 0, 1, -351],
    [4, 0, 0, 1, 331],
    [2, -1, 1, 1, 315],
    [2, -2, 0, -1, 302],
    [0, 0, 1, 3, -283],
    [2, 1, 1, -1, -229],
    [1, 1, 0, -1, 223],
    // TODO: more terms
    [1, 1, 0, 1, 223],
    [0, 1, -2, -1, -220],
    [2, 1, -1, -1, -220],
    [1, 0, 1, 1, -185],
    [2, -1, -2, -1, 181],
    [0, 1, 2, 1, -177],
    [4, 0, -2, -1, 176],
    [4, -1, -1, -1, 166],
    [1, 0, 1, -1, -164],
    [4, 0, 1, -1, 132],
    [1, 0, -1, -1, -119],
    [4, -1, 0, -1, 115],
    [2, -2, 0, 1, 107]
    ];
  
  var El = 0, Er = 0;
  for (var i = 0; i < table_47_A.length; ++i) {
    var a = 1;
    if (table_47_A[i][1] == 1 || table_47_A[i][1] == -1) {
      a = E;
    }
    if (table_47_A[i][1] == 2 || table_47_A[i][1] == -2) {
      a = E*E;
    }
    El += table_47_A[i][4] * a * sind(
      table_47_A[i][0] * D +
      table_47_A[i][1] * M +
      table_47_A[i][2] * M_ +
      table_47_A[i][3] * F);
    Er += table_47_A[i][5] * a * cosd(
      table_47_A[i][0] * D +
      table_47_A[i][1] * M +
      table_47_A[i][2] * M_ +
      table_47_A[i][3] * F);
  }
  
  var Eb = 0;
  for (var i = 0; i < table_47_B_1.length; ++i) {
    var a = 1;
    if (table_47_B_1[i][1] == 1 || table_47_B_1[i][1] == -1) {
      a = E;
    }
    if (table_47_B_1[i][1] == 2 || table_47_B_1[i][1] == -2) {
      a = E*E;
    }
    Eb += table_47_B_1[i][4] * a * sind(
      table_47_B_1[i][0] * D +
      table_47_B_1[i][1] * M +
      table_47_B_1[i][2] * M_ +
      table_47_B_1[i][3] * F);
  }
  for (var i = 0; i < table_47_B_2.length; ++i) {
    var a = 1;
    if (table_47_B_2[i][1] == 1 || table_47_B_2[i][1] == -1) {
      a = E;
    }
    if (table_47_B_2[i][1] == 2 || table_47_B_2[i][1] == -2) {
      a = E*E;
    }
    Eb += table_47_B_2[i][4] * a * cosd(
      table_47_B_2[i][0] * D +
      table_47_B_2[i][1] * M +
      table_47_B_2[i][2] * M_ +
      table_47_B_2[i][3] * F);
  }
  
  // Terms involving A1 due to Venus, A2 involving Jupiter, L_ from earth flattening.
  El +=
    3958 * sind(A1) +
    1962 * sind(L_ - F) +
    318 * sind(A2);
  Eb +=
    -2235 * sind(L_) +
    382 * sind(A3) +
    175 * sind(A1 - F) +
    175 * sind(A1 - F) +
    127 * sind(L_ - M_) -
    115 * sind(L_ + M_);
  //El = -1127527;
  //Eb = -3229126;
  //Er = -16590875;
  // print("El: " + El);
  // print("Eb: " + Eb);
  // print("Er: " + Er);
  // print("L_: " + degree_norm(L_));
  
  var ecliptic_lon_moon = L_ + El / 1000000;
  var ecliptic_lat_moon = Eb / 1000000;
  var dist_moon = 385000.56 + Er / 1000;
  // print("geocentric_lon: " + degree_norm(ecliptic_lon_moon));
  // print("geocentric_lat: " + degree_norm(ecliptic_lat_moon));
  // print("dist_moon: " + dist_moon);
  
  return {latitude: ecliptic_lat_moon, longitude: ecliptic_lon_moon, distance: dist_moon};
};

let bs = (lower, upper, f) => {
  let dt = (upper - lower);
  let m = new Date(lower.getTime() + dt/2);
  
  if (Math.abs(dt) < 2) {
    return m;
  } else if (f(lower) == f(m)) {
    return bs(m, upper, f);
  } else {
    return bs(lower, m, f);
  }
};

let str = (x) => {
  if ("latitude" in x) {
    return "{ latitude " + x.latitude.toFixed(6) + ", longitude " + degree_norm(x.longitude).toFixed(6) + ", distance " + x.distance.toFixed(6) + " }";
  } else if ("right_ascension" in x) {
    return "{ right ascension " + degree_norm(x.right_ascension).toFixed(6) + ", declination " + x.declination.toFixed(6) + ", distance " + x.distance.toFixed(6) + " }";
  } else if ("lat" in x) {
    return "{ lat " + x.lat.toFixed(6) + ", lon " + degree_norm_half(x.lon).toFixed(6) + ", distance " + x.distance.toFixed(6) + " }";
  } else {
    return "" + x;
  }
};

let items = [];

items.push("<h3>Equinoxes</h3>");

vernal_equinox_mean_2000 = bs(new Date("2000-03-15T00:00:00Z"), new Date("2000-04-01T00:00:00Z"), (d) => { return to_spherical(d, sun(d)).lat < 0; });
items.push("Moment of the vernal equinox in the year 2000: " + vernal_equinox_mean_2000.toISOString());
items.push("... at position " + str(sun(vernal_equinox_mean_2000)));
items.push("... at position " + str(to_spherical(vernal_equinox_mean_2000, sun(vernal_equinox_mean_2000))));

vernal_equinox_mean_2001 = bs(new Date("2001-03-15T00:00:00Z"), new Date("2001-04-01T00:00:00Z"), (d) => { return to_spherical(d, sun(d)).lat < 0; });
items.push("Moment of the vernal equinox in the year 2001: " + vernal_equinox_mean_2001.toISOString());
items.push("... at position " + str(sun(vernal_equinox_mean_2001)));
items.push("... at position " + str(to_spherical(vernal_equinox_mean_2001, sun(vernal_equinox_mean_2001))));

items.push("Seconds between these two (length of the 2000-2001 tropical year): " + (vernal_equinox_mean_2001 - vernal_equinox_mean_2000)/1000);

let ms = (lower, upper, f) => {
  let dt = (upper - lower);
  let m1 = new Date(lower.getTime() + dt/3);
  let m2 = new Date(lower.getTime() + 2*dt/3);
  
  let fm1 = f(m1);
  let fm2 = f(m2);
  
  if (Math.abs(dt) < 10) {
    return m1;
  } else if (fm2 < fm1) {
    return ms(m1, upper, f);
  } else {
    return ms(lower, m2, f);
  }
};

items.push("<h3>Sun orbit geometry</h3>");

items.push("The following are all measured at 2025-08-12T05:00:00Z, measured according to the mean axis.");

let target_date = new Date("2025-08-12T05:00:00Z");
let sun_ellipse_target_date = sun_ellipse(target_date);
items.push("Ascending node: " + str(to_spherical(target_date, {latitude:0, longitude:0, distance:1})));
items.push("Argument of periapsis: " + sun_ellipse_target_date.argument_of_periapsis);
items.push("Eccentricity: " + sun_ellipse_target_date.eccentricity);
items.push("Mean anomaly: " + sun_ellipse_target_date.mean_anomaly);
items.push("True anomaly: " + sun_ellipse_target_date.true_anomaly);
items.push("Mean longitude: " + sun_ellipse_target_date.mean_longitude);
items.push("True longitude: " + sun_ellipse_target_date.true_longitude);
items.push("Equation of center: " + sun_ellipse_target_date.EOC);
items.push("Sun position: " + str(sun(target_date)));
items.push("... " + str(to_spherical(target_date, sun(target_date))));

sun_periapsis_mean_2000 = ms(new Date("2000-01-01T00:00:00Z"), new Date("2001-01-01T00:00:00Z"), (d) => { return sun(d).distance; });
// console.log(sun(sun_periapsis_mean_2000));
// console.log(sun(new Date("2000-02-01T00:00:00Z")));
// TODO: check that this distance is actually less than all other dates in 2000.
items.push("Sun reaches periapsis in 2000 at: " + sun_periapsis_mean_2000.toISOString());
items.push("... at position " + str(sun(sun_periapsis_mean_2000)));
items.push("... at position " + str(to_spherical(sun_periapsis_mean_2000, sun(sun_periapsis_mean_2000))));

sun_periapsis_mean_2001 = ms(new Date("2001-01-01T00:00:00Z"), new Date("2002-01-01T00:00:00Z"), (d) => { return sun(d).distance; });
items.push("Sun reaches periapsis in 2001 at: " + sun_periapsis_mean_2001.toISOString());
items.push("... at position " + str(sun(sun_periapsis_mean_2001)));
items.push("... at position " + str(to_spherical(sun_periapsis_mean_2001, sun(sun_periapsis_mean_2001))));

items.push("<h3>Moon orbit geometry</h3>");

items.push("The following are measured on 2025-08-12T05:00:00Z.");

items.push("Moon position: " + str(moon(target_date)));
items.push("... " + str(to_equatorial(target_date, moon(target_date))));
items.push("... " + str(to_spherical(target_date, moon(target_date))));

items.push("<h3>Lengths of day</h3>");

let J2000 = new Date("2000-01-01T12:00:00Z");
let sidereal_J2000 = mean_sidereal_time(J2000);
let sidereal_J2000_plus_360 = bs(new Date("2000-01-01T12:00:00Z"), new Date("2000-01-03T12:00:00Z"), (d) => { return mean_sidereal_time(d) < 360 + sidereal_J2000; });
items.push("Sidereal time at J2000: " + sidereal_J2000);
items.push("The moment in 2000-01-02 when the sidereal time is the same as J2000: " + sidereal_J2000_plus_360.toISOString());
items.push("Seconds between these two (length of the 2000-01-01 to 2000-01-02 sidereal day) in seconds: " + (sidereal_J2000_plus_360 - J2000)/1000);

let sun_J2000 = sun(J2000);
let spherical_sun_J2000 = to_spherical(J2000, sun_J2000);
let sun_J2000_plus_solar_day = bs(new Date("2000-01-01T15:00:00Z"), new Date("2000-01-02T15:00:00Z"), (d) => { return to_spherical(d, sun(d)).lon < spherical_sun_J2000.lon - 360; });
items.push("Position of sun at J2000: " + str(spherical_sun_J2000));
items.push("The moment in 2000-01-02 when the sun crosses the same lon as J2000: " + sun_J2000_plus_solar_day.toISOString());
items.push("... at position: " + str(equatorial_to_spherical(sun_J2000_plus_solar_day, ecliptic_to_equatorial(sun_J2000_plus_solar_day, sun(sun_J2000_plus_solar_day)))));
items.push("Seconds between this and J2000 (length of the 2000-01-01 to 2000-01-02 solar day) in seconds: " + (sun_J2000_plus_solar_day - J2000)/1000);

items.push("<h3>Nutation</h3>");

items.push("The following are measured on 2025-08-12T05:00:00Z.");

let nut_target_date = nutation(target_date);
items.push("Delta longitude: " + nut_target_date.delta_longitude);
items.push("Delta obliquity: " + nut_target_date.delta_obliquity);



for (let i = 0; i < items.length; ++i) {
  let el = document.getElementById("items");
  el.innerHTML += "<p>" + items[i] + "</p>";
}

