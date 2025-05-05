== Moon clock
=== wip

I was recently giften a link()[Bangle.js], a simple programmable watch. I figured I should make something for it.

Lots of smartwatches have a phase-of-the-moon clock face, and Bangle.js doesn't have on listed in the app store, so I decided I'd try to make one.

[image]

It shows current phase of the moon, the correct angle as viewed from a particular place on earth, and illumination percentage. I also added the current ISO 8601 timestamp at the bottom because I look at logs a lot and it's useful to me to be able to say "oh that log happened 2 hours ago" without doing timezone offset math.

As extra features, it turns red when low in the sky, as well as during a lunar eclipse. During a solar eclipse, I draw the sun as well, so you can see it happening on your watch as well.

Unfortunately, it's not perfect. In actuality, the moon changes size quite a bit, and the watch version doesn't. Also, the moon texture isn't rotated to fit the phase angle, since that really messes with the dithering.

I learned about astronomical algorithms from this little project. I want to write about it here: what I know, what I've learned, what I think. All 3 of those things will probably just be nonsense. Oh well.

# The book

I have no education in astronomy. I have skimmed half of one book on the subject. That book is Astronomical Algorithms, Second Edition by Jean Meeus, published in 1998. From what I gathered online, this book is really the go-to for anyone wanting to do this sort of thing. If you use like a python or go or js or whatever library to calculate the current moon phase or eclipse time or easter or whatever, it's probably written by some shitty programmer like me, and not a professional astronomer. And so that library should probably be referencing this book.

The book is pretty cool. It dispenses with the "why"s of the calculations, just gives the "what"s. Though, it's no so stingy with its words that you're not able to learn a great deal from it. The only main topic that it doesn't cover is the positions of various important stars, constellations, and comets.

The book is also an anachronism. It takes great pains to talk about ancient computers, how to compute things in BASIC, reducing `a*x + b*x*x` to `x*(b*x + a)`, how many digits are stored in an HP-85, etc. I enjoyed those bits. They're a fun look into computing history.

The book is also pretty good at being practical when it comes to numerical precision. If you're trying to center a telescope on Jupiter, you only really need 3 decimal places of precision when its location is expressed in degrees.

I will not be taking this approach. I will be as pedantic and precise as I possibly can. While approximation is a useful skill, you can only do it effectively if you already have a good idea of how much error is there already. If you say "oh, that parameter is small, we can ignore that", but in reality you have no idea if that parameter really is small, I think the result is worse than if you just stuck with unnecessary precision.

There are also a bunch of things that seem very old-fasioned to me. I'll be talking about that.

# Time

Time is hard.

Luckily, time travels pretty much the same everywhere on Earth, so that's not a problem.

Time is tracked in 2 main ways:

- Observation of the motion of the Earth via the position of the sun, moon, or stars in the sky.
- Observation of known periodic physical phenomina on Earth, like swings of a pendulum, or atomic clocks.

Both of these kinds are useful for different things.

Time measured with the motion of the sun is called solar time. A "day" is the amount of time it takes the sun to do exactly 1 revolution around Earth, and is called a solar day or a synodic day. Throughout the year a solar day varies by a few minutes due to Earth's elliptical orbit, by a few seconds here and there due to Earth's irregular rotation, and will change much more over the millenia. On average, though, currently, a mean solar day is about 86400.0047 [todo: check this] seconds. More about exactly what that means in a bit. [todo: more about UT1, UTC, etc]

Time measured with the position of the moon is called lunar time. A lunar month is the amount of time the moon takes to do one full phase cycle, from full moon to full moon. This one is a bit rarer to see in the wild. Again, this can change with the irregularities of Earth's orbit, and will change more over the millenia. On average, currently, a mean lunar month is about [] seconds.

Time measured with atomic clocks is called atomic time. [more]

There is also the time between the exact moments of the March equinox each year, called a tropical year. This is measured at the moment the sun is directly over the equator on the day of the equinox. This will happen each year at a specific longitude. These longitudes are very close together year after year, but it does drift [todo: by about how much per year?]. This spot on the equator is called the "ascending node." If you count the number of times the sun passes the ascending node (taking into account the amount that it needs to be continously precessing) between topical years, you get a whole number, [todo]. The amount of time between these passes is called a sidereal day. Same caveat as above, a tropical year takes on average [todo:], and a sidereal day is around [todo:].

Since the sun's ascending node is pretty stable from day to day, and the Earth's rotation is pretty stable from day to day, you can ask "given my current longitude, how far away am I from the ascending node?", which in turn is a very 

[image of path of sun on earth to show the equinox position, exaggerated for effect]
[image of path of sun on earth, real, large?]

If you want to get away from tracking the position of the sun, the next best thing is tracking the positions of distant stars. Thankfully, these don't change much. The very distant ones at least. The amount of time it takes a distant star to cross the same longitude is a stellar day. The amount of time it takes for a star to return to the same spot in the sky is, confusingly, NOT called a stellar year, but is instead called a sidereal year. Actually, due to the slow axial drift the star doesn't actually reach the exact same spot in the sky from year to year, but you can calculate when it *would* have without the drift, from other observations.

Actually, in addition to the slow drift, Earth's axis wobbles on a period of about [TODO: how long?], so these tropical years and sidereal days and stellar days and ascending nodes are actually determined relative to the *mean* equator instead. We'll talk about this later.

In Astronomical Algorithms, time is mostly tracked using Julian days. This is an approximation of a solar day, set to be exactly 86400 seconds. A Julian year is also an approximation of a tropical year, set to be exactly 356.25 Julian days, and a Julian century is exactly 36525 Julian days. [todo: is this right? I don't think so. None of the numbers add up right.]

Actually, most algorithms use a Julian day number, which is a count of how many Julian days, including fractions of days, that have ellapsed since... well, noon at 0° longitude on January 1 4713 BC according to the Julian calendar. But that's a little confusing due to calendar issues. So you can also think of it as the count of days, positive or negative, since noon January 1 2000 AD, plus 2451545. Alternatively, it's also the count of days since the Unix epoch, midnight Janurary 1 1970 AD, plus 2440587.5.

The book gives an algorithm for calculating the Julian day number from the current day, month, year, and time. This algorithm is valid for all dates since the earth started spinning.

```
// Dates after October 15 1582 AD (the Gregorian calendar reform) are assumed to be Gregorian calendar dates, and dates before that are assumed to be Julian calendar dates.
var julian_day = (date) => {
  var Y = date.getFullYear();
  var M = date.getMonth() + 1;
  var D = date.getDate() + date.getHours()/24 + date.getMinutes()/1440 + date.getSeconds()/86400 + date.getTimezoneOffset()/1440;
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
```

Actually, most algorithms in the book are built off of dynamical time. The book uses a very odd measure of dynamical time:

```
var dynamical_time = (date) => {
  var JD = julian_day(date);
  var DT = 68; // This must be read out from a table.
  var JDE = JD + DT/86400;
  
  var T = (JDE - 2451545) / 36525;
  return T;
};
```

## Cometary

Hopefully I'm not not the only one that hates that "Universal time" isn't the universal one, and "dynamical time" is the one that ticks at an unchanging static rate. It's needlessly confusing.

Amusingly, the book predicts $\Delta T$, the number of seconds between universal and dynamical time, to be around +80s in 2015. Jean Meeus couldn't have known that the graph of $\Delta T$ over time would flatten out around the year 2000. In actuality, $\Delta T$ is actually +68 in 2015.

[talk about exactly where on earth the equinox happens. Like, what longitude?]

The big thing about all this, though, is it all seems just very old-fashioned. Like, This book was written after radio time signals, like WWV, were implemented around the world. It was also written after NTP was introduced, though I don't know how widespread it was in 1991 when the first edition was published.

What I'm trying to say is that, for an average person trying to program one of these algorithms, or for an average user of one of these algorithms, you're going to be using a computer. That computer has some natural notion of time, and some derived quantities that are going to be easy to access. Those are:

- Current date/time UTC
- Current Unix time
- Current count of seconds since 1970-01-01T00:00:00

UTC cooresponds to solar time, "count of seconds" cooresponds to dynamical time, and Unix time cooresponds to Julian days. These are the 21st century ways of talking about time on earth. All that stuff about the equinoxes is, in my opinion, overly complicated and not necessary.

An easier version of Julian day numbers would be something like:

```
var julian_day = (date) => {
  // date.getTime() in javascript follows unix time, so the count of SI seconds since 1970-01-01T00:00:00,
  // minus the number of leap seconds elapsed.
  var JD = date.getTime()/1000.0/60/60/24 + 2440587.5;
  return JD;
};
```

# Position

Position is hard.

The basic problem is that everything is moving.

The sun and moon are moving. The earth's axis is moving relative to them. The stars are moving, as is their places in the sky. These can't just be averaged away either.

If you were to teleport 10000 years into the future, all of the constellations would be in all the wrong places in the sky, and some of the constellations would look weird because their individual stars moved in different directions. The sun's track through the sky would be off, as would the moon. When you teleport in, it wouldn't be the same season, even if it was exactly 10000 years to the day. You might not even appear on land. Not because of sea levels rising, but because the continents have physically moved out from under you. Earth's axis of rotation would be at a different spot. If you teleport holding a magnetic compass, it would point in a different direction.

Before getting into the actual position of the sun and moon, I should first go over all the stuff that has to be accounted for separately.

## Stuff that influences position

Also as I understand it, the book gives formulas for computing the *actual* positions of the various bodies, not apparent positions, so a delay should be applied to account for time it takes light to travel and how fast it's moving. [calculate the time dialation of jupiter and compare it to its moving speed].

When it comes to computing where a body is visually in the sky, there's also the effect of parallax. Depending on which side of the earth you're on, or when in the year you are, you will see different bodies at slightly different angles in the sky. These effect the sun and moon and planets greatly. Astronomical Algorithms says that there are only 13 stars brighter than magnitude 9.0 whose parallax exceeds 0.00007 degrees.

There's also the parallactic angle, the angle that the body appears to be rotated, which changes throughout the day and the body moves across the sky. [TODO: image]

Conceptually, Earth spins on an axis at a rate of one revolution per "day" (solar, sidereal, etc). However, as mentioned above, the Earth's axis actually wobbles a bit due to the pull of various stellar bodies. This wobbling gets decomposed into several types:

First is nutation. The Earth's axis of rotation wobbles around a "mean" axis, like pictured below. The largest term has a period of ~18.6 years. [todo: by how much?]

[animation of nutation, exagerated?]

```
nutation = (date) => {
}
```

Second is precession. The Earth's axis rotates around the normal vector of the ecliptic very slowly, with a period of about 26000 years. Currently, our axis is pointed very close to Polaris. In 13000 years our axis will point as far away as [todo] before heading back to Polaris.

[image of precession]

[image of what stars and constellations the north pole will be at at what time.]

In addition to precession, the ecliptic plane also rotates slowly. [todo more explanation of this]. This has a period of roughly 2.7 million years.

Fourth is unpredictable rotation. The Earth's rotation can speed up or slow down slightly for many reasons. [todo: between 0 and 2 seconds/decade recently]. We talked about this already.

[todo: polar motion relative to crust]

There's also of course the effects of proper motion, which is just a fancy way of saying that objects in the universe are moving.

Along a similar vein, there's the effects of relativity. Aberration is the big one, which is where stars will appear in slightly different positions at different times of the year due to different relativistic length contactions when Earth's velocity changes. This affects all stars, by upwards of ~0.005 degrees.

Also of course is light deflection of gravity. This one, I have no idea. I'm very slowly working through link(https://www.amazon.com/Course-Differential-Geometry-Readings-Mathematics/dp/8185931674)[A Course in Differential Geometry and Lie Groups], so maybe one day I'll understand this stuff.

... Yeah. I think that's about everything. At least the lower order terms.

## Coordinate systems

As we've talked about, everything is moving. To construct a coordinate system we need, at the very least, an origin point and two non-colinear vectors.

So it's hard to establish a good coordinate system based on observable things. At least, that's the case if you want to be able to predict where things in the sky are hundreds or thousands of years in the future or past. There are a couple things you can do though:

- Construct a coordinate system based on distant stars, the old classic. [TODO: how far away? Can they be in the same galaxy?]
- Construct a reference frame based on something that is conserved. For example, the average longitudinal movement of the all of the Earth's tectonic plates must be 0. Any value other than 0 would be indistinguishable from irregular rotation around earth's axis. This is how the IERS Reference Prime Meridian is maintained.
- Construct a coordinate system based on something that changes, but whose higher-order terms are fairly small. You recalibrate every so often, and just deal with it.

The book takes the third approach.

There are so many coordinate systems used in the book.

- Equatorial: "horizontal" angles measured from the sun's ascending node, "vertical" angles measured how you think. Angles measured relative to the center of the Earth. This one is basically your normal lat/lon, but where the horizontal angle is measured [0, 360) and not [-180, 180), and are measured from the ascending node instead of the equator/prime meridian intersection. The "horizontal" angle is called the "right ascension", and the "vertical" angle is called the "declination". These angles are measured geocentrically, not geodetically.
- Ecliptic: "horizontal" and "vertical" angles are measured the same way, but relative to the ecliptic plane (the plane of the sun's orbit) instead of the equator. These are called "longitude" and "latitude", respectively. Yes, I know this is confusing.
- Other: For the moon calculation, we won't be working in the above coordinate systems, because the moon's orbit lies in a slightly different plane, something around 1 degree off. [todo]
- An ecliptic coordinate system, but centered on the solar system's barycenter, used to calculate the "mean distance" to planets.

We're mostly going to be working with equatorial and ecliptic coordinate systems.

But how would they work? They're both based on the intersection of the equatorial and ecliptic planes. But as we've seen, those planes move relative to each other, and relative to distant stars

For the field of astronomy, the answer is "it's too complicated, so fuck it." In the above list of complications that influence the angles and positions of these planes, two of them work on human timescales: nutation and polar motion.

Nutation is a large enough effect, and happens with a short enough period that it has to be taken into account in the coordinate system. Otherwise, every 10 years all of the starts and planets in the sky will be whole degrees off [todo: check].



```
var image = atob("sLAB//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////6AAL////////////////////////9QBVVRX//////////////////////4AAAAAAP/////////////////////QAAVVVUBf////////////////////AAAAACAAD////////////////////AAAVVVVVVX//////////////////+AAAAAKoAAA//////////////////9VVVVVVVVUVVf////////////////+AAAACqqqqAIL////////////////9FVVVVVVVVVVVX///////////////+AACqqqq6/6AAi////////////////BVVVVVVVVVVVVV///////////////ACqr/qqqq/qCCgP//////////////VVVVVVVVVVVVVVV//////////////gCr/+qqqqqqqAKgP/////////////1VVVVVVVVVVVVVVVf////////////wAqruqoKqiqqqqKqD////////////1VVVVVVVVVVVVVVVVf///////////4Cv6qi6oqqqqqqqICD///////////9VVVVVVVVVVVVVVVVVf//////////+ivqqv/qiqqKqqqIKCj///////////VVVVVVVVVVVVVVVVVVf//////////qrqqru//qqir+quqgAr//////////1VVVVVVVVVVVVVVVVVVf/////////7r+oq////qoKr+r4qACr/////////9VVVVVVVVVVVVVVVVVVVf////////+//qv/////qiqrvv6AACD/////////VVVVVVVVVVVVVVVVVVVVf////////v/qr//////qr/7++qAAKD////////1VVVVVVVVVVVVVVVVVVVVf/////////+q/////6+o///6qACAAD///////9VVVVVVVVVVVVVVVVVVVVVf/////////6r/////+/r///4qAAKIH///////1VVVVVVVVVVVVVVVVVUVVV///////7/+q//////6+v///+gAgKov//////9VVVVVVVVVVVVVVVVVVVVVV//////+//77//////67////6AKqqoP//////VVVVVVVVVVVVVVVVVVVVVVV//////7/////////6r/////oIqo/qf/////9VVVVVVVVVVVVVVVVVVVVVVX/////+/////////7+q/////qqqr/o//////VVVVVVVVVVVVVVVVVVVVVVVX/////////////////r////+q4iP/r/////9VVVVVVVVVVVVVVVVVVVVVVVf////+/////////6r+v////6roA//r/////VVVVVVVVVVVVVVVVVVVVVVVVf//////////////+6q/////6/6A/+P////9VVVVVVVVVVVVVVVVVVVVQVVV///////////////7qL///////qD/6v////VVVVVVVVVVVVVVVVVVVVVVVVV///////////////+qv//////+qD/q////9VVVVVVVVVVVVVVVVVVVVVVVVX///+//+////////6u//47v//+oL+q////VVVVVVVVVVVVVVVVVVVVXVVVVX//////7//7/v//+q///r/////oKqj///9VVVVVVVVVVVVVVVVV1VVVVVVVf/////+P///////qv/6+v////6oq6v///1VVVVVVVVVVVVVVVVVVVVVVVVV///7/////////+vv///6/////v6KqP///VVVVVVVVVVVVVVVVVVVVVVVVVX///7////////uv/////r/////76qq///1VVVVVVVVVVVVVV1VXVVVVVVVVX/////////66q7v////6v////+r6qr///VVVVVVVVVVVVVVVVVVVVVVVVVVf////////+rqqr//7//qv//////7uv//9VdVVVVVVVVVVVVVVVVVVVVVVVV//+//////6qqqv/+ruqK/////v//6///1X1VVVVVVVVVVVVVVVVVVVVVVVX//7//////qqCq//qquqq///r7//+r//9VV1VVVVVVVVVVVVVVVVVVVVVVVf//v//////qgL//+qogCp//+qv//6r//1Vf1VVVVVVVV1VVVVVVVVFVVVVV//+////+//6r///6qqgCr//4q///qv//VVdVVVVVVVVXVVVVVVVVVVVVVVV//z////6v/q/////6oAiq/+qq//+q//9VVdVVVVVVVVVVVVVVVVVVVVVVVX//v///+q+vr////+6IACCv+qq//6r//1VVV1VVVVVVVVVVVVVVVVVVVVVVf/+v///+r/+r///r+iCogAuoiv/+Kv//VVVVVVVVVVVVVVVVVVVVVVVVVVV//6v///6//7q//6rqgKIAD/qCv/oq//9VVVVVVVVVVVVVVVVVUVVVVVVVVX//i///////66//6qqoioAq6oCv+ir//1VVVVVVVVVVVVVVVVVRVVVVVVVVf/8K////////7/6iqqgAACqqqCvuqv//VV9VXVVVVVVVVVVVVVVVVVVVVVV//wr////////q6ioqoAAACCPqKq6q//9VVVVVVVVVVVVVVVRVVVVVVVVVVX//KP/////7/+r+qqqgCIAAKv4qLqr//1VXVX1VVVVVVVVVVVVFVVVVVVVVf/+q///////+6v6qqqgAAAAL+Ag6qv//VVVV3VVVVVVVVVVVVVVBVVVVVVV//6L/////+//q/+qqqIgAAAv+Iq6q//9VVVXdVVVVVVVVVVVVVUFVVVVVVf//oL/////6//r/6qqoigIACv4q6Kr//9VXdVVVVVVVVVVVVVVVVBVVVVVV//+or/////r//7/qqoKACAAK/qrgqf//1VVVVVVVVVVVVVVVVVVUVVVVVVX//6ru////+v//r/6qqoAIAAK6qqir///VVVVVVVVVVVVVVVVVVVVVVVVVVf//yuv/////////+qqiCiAAAoKqoqv//9VVVVVVVVVVVVVVVVVVVVVVVVVX///o6//////+///+qoCoAiACogAoi///9VVVVVVVVVVVVVVVVVVVVVVVVVf//+Cq///v//7///qgiKAAIAIKAAAn///1VVVVVVVVVVVVVVVVVVUVVVUVV///8Kq+v+v/7v//+oKooAKAAAoAAC////VVVVVVVVVVVVVVVVVVVFVVUBVX///4ii7qq//7///6ioKACIAACAAAL////VUVVVVVVVVVVVVVRVVVVVVQBV////qqiv6q7+v///qCggACAAAAAAA////9VVVVVVVVVVVVVVVFVVVVVVAVX////gqq+qr+u+///oICACgAAAAAAL////9VVVVVdVVVVVVVFVVVFVVFUBV////+qyqqP/6/////gAAAIAgAAAAA/////1VVVVVVVVVVVVVRVVRVVVVAFX////+qiqq///u///+gAAAAAAAAAAL/////VVVVVVVVVVVVVRRVVFVVVVFV/////6qCqr//////6gAAAAAAAAAAA//////VVVVVVVVVVVVVQFURVVVVRFX/////4AAqv//6+77oAAAAAAAgAAAL//////VVVVVVVVVVVQAVVVVVVVUVV//////gAAKP/+rqqoAAAAAAAAAACq//////9VFVVVVVVVVQAFRRVVVVUVVX//////gACAv/q6oAAAAAAAAAAAAIr//////9UFVVVVVVRVAAAVVVVVVVVV///////KAICq6r/gAAAAAAAACAAAi///////1VVRVVVVVREAAABVVVVVVVf//////+CgoAKq+qgAAAAAAAAAAAKv///////1VVVVVVVVRAAAFBRVVVBVV///////+CIgAqqqgAAAAAAAAAAACD////////1VVVVVVVVRBABUVVVURVVf///////+Kqqq6qiAAAAAAAAAAACC/////////1VVVVVVVVRVAAFVVVVVVX////////+IqiK6CqoAAAAAAAAAAAv/////////1VVVVVVVVEFBAFVVVVVV/////////8ioqqqAAAAAAAAAAAACL//////////VVVVVVVVUVQAQVVVVVVf/////////8KoqigCIAAAAAAAAAAAP//////////VVVVVVVVQAAAVVVVVVX//////////+KKqqiCIAAAAAAAAAAD///////////1VVVVVVVEBBQVVVVVV///////////+CqqqqAgAAAAAAAAAA////////////1VVVVVVUQABVVVVVVf///////////+CqqqqAgAAAAAAAAAf////////////1VVVVVVRQUBQVVVVf/////////////AoKqqKAAAAAAAAAP/////////////9VVVVVVUEBVUVVQX//////////////oKqqoAAAAAAAAAD//////////////9VVVVVVUEVVFRVV///////////////4KAqoAAAAAAAAD////////////////VVVVVVUABEAFV////////////////+CoAAAAAAAAAD/////////////////1VVVVVAARAAF//////////////////gAAAAAAAAAD//////////////////9VVVVVAAAAF///////////////////4AAAAAAAAD////////////////////1VRVVQAAX/////////////////////gAAAAAA///////////////////////VQQAQF////////////////////////+AAAv//////////////////////////X///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8=");

var r2d = (x) => { return x * 180 / Math.PI; };
var d2r = (x) => { return x * Math.PI / 180; };

//var cos = (x) => { return Math.cos(x); };
//var sin = (x) => { return Math.sin(x); };
var asind = (x) => { return r2d(Math.asin(x)); };
var acos = (x) => { return Math.acos(x); };
var atan2d = (y, x) => { return r2d(Math.atan2(y, x)); };

var cosd = (x) => { return Math.cos(d2r(x)); };
var sind = (x) => { return Math.sin(d2r(x)); };
var tand = (x) => { return Math.tan(d2r(x)); };

var degree_norm = (x) => { return x - 360*Math.floor(x/360); };

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

var julian_day = (date) => {
  // TODO: these are all in local time, fix.
  //print("date: " + date.getDate() + " " + date.getHours() + " " + date.getTimezoneOffset());
  //print(date.toJSON());
  //date = new Date(date + date.getTimezoneOffset()*60000);
  //print("date: " + date.getDate() + " " + date.getHours() + " " + date.getTimezoneOffset());
  
  /*print("my JD: " + (date.getTime()/1000.0/60/60/24 + 2440587.5));
  var Y = date.getFullYear();
  var M = date.getMonth() + 1;
  var D = date.getDate() + date.getHours()/24 + date.getMinutes()/1440 + date.getSeconds()/86400 + date.getTimezoneOffset()/1440;
  //D = date.getDate() + ;
  //print((new Date(date.toJSON())).getHours());
  //var Y = 1992; var M = 4; var D = 12;
  //var Y = 1992; var M = 10; var D = 13;
  //var D = 6.5 + 6.0/24;
  //var D = 7.0 + 3.0/24 + 6.0/24;
  // print(Y); print(M); print(D);
  //var Y = 1970; var M = 1; var D = 1;
  if (M == 1 || M == 2) {
    M = M + 12;
    Y = Y - 1;
  }
  var A = Math.floor(Y / 100);
  var B = 2 - A + Math.floor(A / 4);
  var JD = Math.floor(365.25 * (Y + 4716)) + Math.floor(30.6 * (M + 1)) + D + B - 1524.5;
  print("Julian Day: " + JD);
  return JD;*/
  
  var JD = date.getTime()/1000.0/60/60/24 + 2440587.5;
  print("Julian Day: " + JD);
  return JD;
};
var dynamical_time = (date) => {
  var JD = julian_day(date);
  var JDE = JD + 0; //74.5; // TODO: this is an approximation, should add ~80 seconds.
  
  var T = (JDE - 2451545) / 36525;
  return T;
};

// GPS: [prime meridian, other, north pole]
// spherical: [lon (deg), lat (deg), radius]
var spherical_2_GPS = (p) => {
  var x = p[2] * cosd(p[0]) * cosd(p[1]);
  var y = p[2] * sind(p[0]) * cosd(p[1]);
  var z = p[2] * sind(p[1]);
  return [x, y, z];
};
var GPS_2_spherical = (x) => {
  var lon = atan2d(x[1], x[0]);
  var lat = atan2d(x[2], v3_length([x[0], x[1], 0]));
  var rad = v3_length(x);
  return [lon, lat, rad];
};

var equatorial_inv_transform = (date) => {
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
  print("sidereal time: " + degree_norm(sidereal_time));
  
  sidereal_time = -sidereal_time;
  var equatorial_inv = [
    [cosd(sidereal_time), sind(sidereal_time), 0],
    [-sind(sidereal_time), cosd(sidereal_time), 0],
    [0, 0, 1]];
  return equatorial_inv;
};
var ecliptic_inv_transform = (date) => {
  var T = dynamical_time(date);
  
  var obliquity_ecliptic_base = 
      23.439291 +
      -0.0130042 * T +
      -0.000000164 * T * T +
      0.00000050361 * T * T * T; // Chapter 22
  var obliquity_ecliptic_delta = 0; // TODO: Chapter 22.3 the effect of the other kind of precession
  var obliquity_ecliptic = obliquity_ecliptic_base + obliquity_ecliptic_delta;
  print("obliquity_ecliptic: " + degree_norm(obliquity_ecliptic));
  
  var equatorial_inv = equatorial_inv_transform(date);
  var ecliptic_to_equatorial = [
    [1, 0, 0],
    [0, cosd(obliquity_ecliptic), sind(obliquity_ecliptic)],
    [0, -sind(obliquity_ecliptic), cosd(obliquity_ecliptic)]];
  var ecliptic_inv = m3_mul(equatorial_inv, ecliptic_to_equatorial);
  return ecliptic_inv;
};

var moon_pos = (date) => {
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
  //print(mean_elongation_of_moon % 360);
  //print(mean_elongation_of_moon - 360*Math.floor(mean_elongation_of_moon/360));
  print("mean anomaly of sun: " + degree_norm(mean_anomaly_sun));
  print("mean elongation: " + degree_norm(mean_elongation_of_moon));
  
  var mean_anomaly_moon =
      134.9633964 +
      477198.8675055 * T +
      0.0087414 * T*T +
      T*T*T / 69699 +
      -T*T*T*T / 14712000;
  print("mean anomaly of moon: " + degree_norm(mean_anomaly_moon));
  
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
  print("A1: " + degree_norm(A1));
  print("A2: " + degree_norm(A2));
  print("A3: " + degree_norm(A3));
  print("E: " + E);
  print("D: " + degree_norm(D));
  //print("M: " + degree_norm(M));
  print("M_: " + degree_norm(M_));
  print("F: " + degree_norm(F));
  
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
    ];
  
  /*var El =
      6288774 * sind(0*D + 0*M + 1*M_ + 0*F) +
      1274027 * sind(2*D + 0*M - 1*M_ + 0*F);
  var Er =
      -20905355 * sind(0*D + 0*M + 1*M_ + 0*F) +
      -3699111  * sind(2*D + 0*M - 1*M_ + 0*F);*/
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
  print("El: " + El);
  print("Eb: " + Eb);
  print("Er: " + Er);
  print("L_: " + degree_norm(L_));
  
  var ecliptic_lon_moon = L_ + El / 1000000;
  var ecliptic_lat_moon = Eb / 1000000;
  var dist_moon = 385000.56 + Er / 1000;
  print("geocentric_lon: " + degree_norm(ecliptic_lon_moon));
  print("geocentric_lat: " + degree_norm(ecliptic_lat_moon));
  print("dist_moon: " + dist_moon);
  
  /*var right_ascension_moon = atan2d(sind(geocentric_lon_moon) * cosd(obliquity_ecliptic) - tand(geocentric_lat_moon) * sind(obliquity_ecliptic), cosd(geocentric_lon_moon));
  var declination_moon = asind(sind(geocentric_lat_moon)*cosd(obliquity_ecliptic) + cosd(geocentric_lat_moon)*sind(obliquity_ecliptic)*sind(geocentric_lon_moon));
  print("right_ascension_moon: " + right_ascension_moon);
  print("declination_moon: " + declination_moon);
  
  var geocentric_lat_moon = declination_moon;
  var geocentric_lon_moon = right_ascension_moon + sidereal_time;
  
  var x = dist_moon * cosd(geocentric_lon_moon) * cosd(geocentric_lat_moon);
  var y = dist_moon * sind(geocentric_lon_moon) * cosd(geocentric_lat_moon);
  var z = dist_moon * sind(geocentric_lat_moon);
  // return [x, y, z];
  moon = [x, y, z];*/
  
  var x = dist_moon * cosd(ecliptic_lon_moon) * cosd(ecliptic_lat_moon);
  var y = dist_moon * sind(ecliptic_lon_moon) * cosd(ecliptic_lat_moon);
  var z = dist_moon * sind(ecliptic_lat_moon);
  moon = [x, y, z];
  
  var ecliptic_inv = ecliptic_inv_transform(date);
  moon = mv3_mul(ecliptic_inv, moon);
  
  {
    var moon2 = mv3_mul(m3_inv(equatorial_inv_transform(date)), moon);
    var moon3 = GPS_2_spherical(moon2);
    print("aa: " + degree_norm(atan2d(moon2[1], moon2[0])));
    print("bb: " + degree_norm(asind(moon2[2] / dist_moon)));
    print("cc: " + moon3);
  }
  
  return moon;
};

var sun_pos = (date) => {
  var T = dynamical_time(date);
  
  var mean_anomaly_sun =
      357.5291092 +
      35999.0502909 * T +
      -0.0001536 * T*T +
      T*T*T / 24490000;
  print("mean anomaly of sun: " + degree_norm(mean_anomaly_sun));
  
  var obliquity_ecliptic_base = 
      23.439291 +
      -0.0130042 * T +
      -0.000000164 * T * T +
      0.00000050361 * T * T * T;
  var obliquity_ecliptic_delta = 0; // TODO: Chapter 22
  var obliquity_ecliptic = obliquity_ecliptic_base + obliquity_ecliptic_delta;

  var equatorial_inv = ecliptic_inv_transform(date);
    
  var eccentricity_earth =
      0.016708634 +
      -0.000042037 * T +
      -0.0000001267 * T * T;
  var M = // mean anomaly of the sun
      357.52911 +
      35999.05029 * T +
      -0.0001537 * T * T;
  var C = // sun's equation of center
      (1.914602 - 0.004817*T - 0.000014*T*T) * sind(M) +
      (0.019993 - 0.000101*T) * sind(2*M) +
      0.000289 * sind(3*M);
  var v = M + C; // sun's true anomaly
  var dist_sun = 1.000001018 * (1 - eccentricity_earth*eccentricity_earth) / (1 + eccentricity_earth * cosd(v));
  var L0 = // geometric mean longitude of the sun (aka mean equinox of the date)
      280.46646 +
      36000.76983 * T +
      0.0003032 * T * T;
  var true_longitude_sun = L0 + C;
  var declination_sun = asind(sind(obliquity_ecliptic) * sind(true_longitude_sun));
  var right_ascension_sun = atan2d(cosd(obliquity_ecliptic) * sind(true_longitude_sun), cosd(true_longitude_sun));
  print("eps_0: " + obliquity_ecliptic_base);
  print("eps: " + obliquity_ecliptic);
  print("R: " + dist_sun);
  print("L0: " + degree_norm(L0));
  print("M: " + degree_norm(M));
  print("C: " + C);
  print("e: " + eccentricity_earth);
  print("alpha: " + right_ascension_sun);
  print("delta: " + declination_sun);
  
  dist_sun *= 149597870.700;
  var x_sun = dist_sun * cosd(right_ascension_sun) * cosd(declination_sun);
  var y_sun = dist_sun * sind(right_ascension_sun) * cosd(declination_sun);
  var z_sun = dist_sun * sind(declination_sun);
  sun = [x_sun, y_sun, z_sun];
  print("sun before: " + v3_norm(sun) + "; " + GPS_2_spherical(sun));
  sun = mv3_mul(equatorial_inv, sun);
  print("sun after: " + v3_norm(sun) + "; " + GPS_2_spherical(sun));
  return sun;
};

var me_pos = () => {
  var lat_me = 34.7;
  var lon_me = -86.5;
  
  // TODO: use the geodetic up vector instead.
  var up_me = [cosd(lon_me)*cosd(lat_me), sind(lon_me)*cosd(lat_me), sind(lat_me)];
  var rad_me = 6356.7523;
  var me = [rad_me*up_me[0], rad_me*up_me[1], rad_me*up_me[2]];
  return me;
};

var viewing_xform = (me, moon) => {
  var up_me = v3_norm(me);
  
  // "viewing" basis, modeling my head looking at the moon. x is pointed at the moon (through my eyes), y is pointing out my left ear (right hand rule!), and z is pointing out the top of my head.
  // (viewing -> base) * (viewing position)
  var viewing_x = v3_norm(v3_sub(moon, me));
  var viewing_y = v3_norm(v3_cross(up_me, viewing_x));
  var viewing_z = v3_cross(viewing_x, viewing_y);
  var viewing = [viewing_x, viewing_y, viewing_z];
  // var viewing_inv = m3_inv(viewing);
  return viewing;
};

var local_xform = (me) => {
  // "local" basis: (northward, eastward, upwards)
  // (local -> base) * (local position)
  var z = v3_norm(me);
  var y = v3_norm(v3_cross([0,0,1], z));
  var x = v3_norm(v3_cross(z, y));
  return [x, y, z];
};

var bg_moon;
var percent_illum = 0;
var draw_background_timeout;
var draw_background = () => {
  var date = new Date();
  var moon = moon_pos(date);
  var sun = sun_pos(date);
  var me = me_pos();
  
  var moon_color = g.toColor(1,1,1);
  {
    var local = local_xform(me);
    var local_inv = m3_inv(local);
    
    var moon_dir = v3_sub(moon, me);
    var moon_dir_local = mv3_mul(local_inv, moon_dir);
    var sun_dir_local = mv3_mul(local_inv, v3_sub(sun, me));
    print("me: " + me);
    print("moon: " + moon);
    print("sun: " + v3_norm(sun));
    print("local: " + local);
    print("moon in local coords: " + v3_norm(moon_dir_local) + "; " + GPS_2_spherical(moon_dir_local));
    print("sun in local coords: " + v3_norm(sun_dir_local) + "; " + GPS_2_spherical(sun_dir_local));
    if (0 <= moon_dir_local[2] && moon_dir_local[2] < 0.1) {
      moon_color = g.toColor(1,0,0);
    }
  }
  
  bg_moon = Graphics.createArrayBuffer(176, 176, 1, {msb: true});
  bg_moon.palette = new Uint16Array([g.toColor(0,0,0), moon_color]); // (optional) set a color palette
  bg_moon.clear(true);
  bg_moon.setBgColor(1);
  bg_moon.setColor(0);
  bg_moon.fillRect({x:0,y:0,w:99,h:99,r:8});
  bg_moon.drawImage(image, 0, 0);
  
  var viewing = viewing_xform(me, moon);
  var viewing_inv = m3_inv(viewing);
  print("!! me norm: " + v3_norm(me));
  print("!! moon norm: " + v3_norm(moon));
  print("!! sun norm: " + v3_norm(sun));
  
  {
    var viewing_moon = mv3_mul(viewing_inv, v3_sub(moon, me));
    var viewing_sun = mv3_mul(viewing_inv, v3_sub(sun, me));
    print("viewing_moon: " + viewing_moon);
    print("dot: " + v3_dot(v3_norm(v3_sub(sun, moon)), v3_norm(v3_sub(me, moon))));
    print("viewing_sun: " + v3_norm(viewing_sun));
    print("!! diff: " + v3_norm(v3_sub(viewing_sun, viewing_moon)));
    
    dir = v3_norm(v3_sub(viewing_sun, viewing_moon));
  }
  
  
  // Changing coordinate systems again
  // x: screen rightward
  // y: into screen
  // z: screen upward
  //dir = v3_norm([-1, -1, 1]);
  dir = [-dir[1], dir[0], dir[2]];
  var n2 = [0, 0, 1];
  var n1 = dir;
  var r = v3_norm(v3_cross(n1, n2));
  var e1 = v3_cross(n1, r);
  var sin_angle = v3_length(v3_cross(n2, n1));
  // TODO: test for v3_dot(dir, [0, 0, 1]) != 0
  for (var y = 7; y < 169; ++y) {
    var o2 = [0, 0, 88-y];
    
    var x = v3_mul(-v3_dot(o2, n2) / sin_angle, e1);
    
    var yR = Math.sqrt(81*81 - v3_dot(o2,o2)) + 1;
    
    if (v3_dot(x, x) < 81*81) {
      var d = v3_mul(Math.sqrt(81*81 - v3_dot(x, x)), r);
      var x1 = v3_add(x, d);
      var x2 = v3_sub(x, d);

      if (x[0] <= x2[0] && x1[1] < 0 && x2[1] < 0) {
        bg_moon.drawLine(88-yR, y, 88+x1[0], y);
        bg_moon.drawLine(88+x2[0], y, 88+yR, y);
      }
      if (x2[0] < x1[0] && x1[1] < 0 && x2[1] < 0) {
        bg_moon.drawLine(88+x2[0], y, 88+x1[0], y);
      }
      if (x1[1] < 0 && 0 <= x2[1]) {
        bg_moon.drawLine(88-yR, y, 88+x1[0], y);
      }
      if (0 <= x1[1] && x2[1] < 0) {
        bg_moon.drawLine(88+x2[0], y, 88+yR, y);
      }
      if (0 <= x1[1] && 0 <= x2[1] && x2[0] <= x1[0]) {
        bg_moon.drawLine(88-yR, y, 88+yR, y);
      }
    } else {
      if (v3_dot(o2, n1) < 0) {
        bg_moon.drawLine(88-yR, y, 88+yR, y);
      }
    }
  }
  
  percent_illum = (1 + v3_dot(v3_norm(v3_neg(moon)), v3_norm(v3_sub(sun, moon)))) / 2;
  
  //image.setColor(1).fillRect({x:2,y:2,w:95,h:95,r:7});
  // image.setColor(1).setFont("Vector:30").setFontAlign(0,0).drawString("Hi",50,50);
  //Bangle.setLCDOverlay(image, 0, 0, {id: "myOverlay", remove: () => print("Removed")});
  //g.setColor(0, 0, 0);
  //g.clear();
  //g.drawImage(bg, 0, 0);
  
  draw_background_timeout = setTimeout(() => {
    draw_background();
  }, 1800000 - (Date.now() % 1800000));
};

var draw_with_border = (str, x, y, b) => {
  g.setColor(0, 0, 0);
  for (var dy = -b; dy <= b; dy += 1)
  for (var dx = -b; dx <= b; dx += 1) {
    g.drawString(str, x + dx, y + dy);
  }

  g.setColor(1, 1, 1);
  g.drawString(str, x, y);
};

var draw_timeout;
var draw = () => {
  //var p = percent(new Date());
  
  g.setColor(0, 0, 0);
  
  g.clear();
  g.drawImage(bg_moon, 0, 0);
  
  date = new Date();

  g.setColor(1, 1, 1);
  g.setFont("6x8");
  {
    dummy_date = date;
    dummy_date.setSeconds(0, 0);
    dummy_str = dummy_date.toISOString();
    dummy_str = dummy_str.substring(0, 19);
    g.drawString(dummy_str, (176-6*19)/2, 176-1*8);
  }
  
  g.setFont('6x8:2');
  draw_with_border((['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])[date.getMonth()] + ' ' + date.getDate(), 0, 176-1*8-1*16, 2);
  draw_with_border((['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])[date.getDay()], 0, 176-1*8-2*16, 2);
  
  g.drawString(String(Math.round(percent_illum*100)).padStart(3, ' ') + "%", 176-4*12, 176-1*8-1*16);

  g.setFont("Vector:64");

  const zeroPad = (num, places) => String(num).padStart(places, '0');
  
  date_str = "" + zeroPad(date.getHours(), 2) + ":" + zeroPad(date.getMinutes(), 2);

  g.setColor(0, 0, 0);
  for (var dy = -2; dy <= 2; dy += 1)
  for (var dx = -2; dx <= 2; dx += 1) {
    g.drawString(date_str, 4 + dx, dy + 88 - 32);
  }

  g.setColor(1, 1, 1);
  g.drawString(date_str, 4, 88 - 32);
  
  Bangle.drawWidgets();
  
  if (draw_timeout) {
    clearTimeout(draw_timeout);
  }
  draw_timeout = setTimeout(() => {
    draw();
  }, 60000 - (Date.now() % 60000));
};

Bangle.loadWidgets();
setTimeout(() => {
  // lol, the uploader gets mad if it doesn't hear a response within a second or so of upload, so let's just delay the clock for a second.
  // TODO: figure this out better. I want the clock to start instantly?
  draw_background();
  draw();
}, 1000);
//draw_background();
//draw();
setTimeout(Bangle.drawWidgets,0);

// Show launcher when middle button pressed
Bangle.setUI("clock");
```
