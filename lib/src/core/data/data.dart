import 'package:flutter/material.dart';

import '../constants/constants.dart';

import 'models/movies.dart';

final section1 = List.generate(
  16,
  (index) => Seat(
    isHidden: [0, 1, 4].contains(index),
    isOcuppied: [].contains(index),
  ),
);

final section2 = List.generate(
  16,
  (index) => Seat(
    isHidden: [4, 5, 6, 7].contains(index),
    isOcuppied: [12, 13].contains(index),
  ),
);

final section3 = List.generate(
  16,
  (index) => Seat(
    isHidden: [2, 3, 7].contains(index),
    isOcuppied: [13, 14, 15].contains(index),
  ),
);

final section4 = List.generate(
  20,
  (index) => Seat(
    isHidden: [].contains(index),
    isOcuppied: [1, 2, 3].contains(index),
  ),
);

final section5 = List.generate(
  20,
  (index) => Seat(
    isHidden: [].contains(index),
    isOcuppied: [].contains(index),
  ),
);

final section6 = List.generate(
  20,
  (index) => Seat(
    isHidden: [].contains(index),
    isOcuppied: [14].contains(index),
  ),
);

final seats = [
  section1,
  section2,
  section3,
  section4,
  section5,
  section6,
];

const seatTypes = [
  SeatType(name: 'Available', color: Colors.grey),
  SeatType(name: 'Booked', color: Colors.black),
  SeatType(name: 'Selection', color: AppColors.primaryColor),
];

const dates = [
  MovieDate(day: 11, month: 'OCT', hour: '6:00PM'),
  MovieDate(day: 11, month: 'OCT', hour: '8:00PM'),
  MovieDate(day: 11, month: 'OCT', hour: '9:00PM'),
  MovieDate(day: 11, month: 'OCT', hour: '10:00PM'),
];

final movies = [
  Movie(
    name: 'Greta ',
    image: 'assets/images/greta.jpg',
    screenPreview: 'assets/images/greta.jpg',
    description:
        'A kind-hearted street urchin and a power-hungry Grand Vizier vie for '
        'a magic lamp that has the power to make their deepest wishses come true.',
    type: 'Fantasy',
    hours: 2,
    director: 'Ritchie',
    stars: 5,
    actors: [
      'Jeff Hille',
      'Jane Perry',
      'Colm Feore',
      'Isabella Hupper',
      'Stephen Rea',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Aladdin ',
    image: 'assets/images/aladdin.jpg',
    screenPreview: 'assets/images/aladdin.jpg',
    description:
        'A kind-hearted street urchin and a power-hungry Grand Vizier vie for '
        'a magic lamp that has the power to make their deepest wishses come true.',
    type: 'Fantasy',
    hours: 2,
    director: 'Ritchie',
    stars: 5,
    actors: [
      'Will Smith',
      'Joey Ansah',
      'Naomi Scott',
      'Marwan Kenzari',
      'Nasim Pedrad',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Aladdin 2 ',
    image: 'assets/images/aladdin_2.jpg',
    screenPreview: 'assets/images/aladdin_2.jpg',
    description:
        'A kind-hearted street urchin and a power-hungry Grand Vizier vie for '
        'a magic lamp that has the power to make their deepest wishses come true.',
    type: 'Fantasy',
    hours: 2,
    director: 'Ritchie',
    stars: 5,
    actors: [
      'Will Smith',
      'Joey Ansah',
      'Naomi Scott',
      'Marwan Kenzari',
      'Nasim Pedrad',
    ],
    dates: dates,
    seats: seats,
  ),
];

final series = [
  Movie(
    name: 'Breaking Bad',
    image: 'assets/images/breaking_bad.jpg',
    screenPreview: 'assets/images/breaking_bad.jpg',
    description:
        'A high school chemistry teacher diagnosed with inoperable lung cancer '
        'turns to manufacturing and selling methamphetamine to secure his family\'s future.',
    type: 'Drama',
    hours: 1,
    director: 'Vince Gilligan',
    stars: 5,
    actors: [
      'Bryan Cranston',
      'Aaron Paul',
      'Anna Gunn',
      'Dean Norris',
      'Betsy Brandt',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Stranger ',
    image: 'assets/images/stranger_things.jpg',
    screenPreview: 'assets/images/stranger_things.jpg',
    description:
        'When a young boy disappears, his mother, a police chief and his friends '
        'must confront terrifying supernatural forces to get him back.',
    type: 'Sci-Fi',
    hours: 1,
    director: 'The Duffer Brothers',
    stars: 5,
    actors: [
      'Millie Bobby Brown',
      'Finn Wolfhard',
      'Winona Ryder',
      'David Harbour',
      'Gaten Matarazzo',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'The Crown',
    image: 'assets/images/the_crown.jpg',
    screenPreview: 'assets/images/the_crown.jpg',
    description:
        'Follows the political rivalries and romance of Queen Elizabeth II\'s reign '
        'and the events that shaped the second half of the twentieth century.',
    type: 'Drama',
    hours: 1,
    director: 'Peter Morgan',
    stars: 5,
    actors: [
      'Claire Foy',
      'Olivia Colman',
      'Imelda Staunton',
      'Matt Smith',
      'Tobias Menzies',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'The Witcher',
    image: 'assets/images/the_witcher.jpg',
    screenPreview: 'assets/images/the_witcher.jpg',
    description:
        'Geralt of Rivia, a solitary monster hunter, struggles to find his place '
        'in a world where people often prove more wicked than beasts.',
    type: 'Fantasy',
    hours: 1,
    director: 'Lauren Schmidt',
    stars: 5,
    actors: [
      'Henry Cavill',
      'Anya Chalotra',
      'Freya Allan',
      'Joey Batey',
      'MyAnna Buring',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Wednesday',
    image: 'assets/images/wednesday.jpg',
    screenPreview: 'assets/images/wednesday.jpg',
    description:
        'Follows Wednesday Addams years as a student at Nevermore Academy, '
        'where she attempts to master her psychic ability and solve a mystery.',
    type: 'Mystery',
    hours: 1,
    director: 'Tim Burton',
    stars: 5,
    actors: [
      'Jenna Ortega',
      'Gwendoline Christie',
      'Riki Lindhome',
      'Jamie McShane',
      'Hunter Doohan',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Peaky Blinders',
    image: 'assets/images/peaky_blinders.jpg',
    screenPreview: 'assets/images/peaky_blinders.jpg',
    description:
        'A gangster family epic set in 1900s England, centering on a gang who '
        'sew razor blades in the peaks of their caps, and their fierce boss Tommy Shelby.',
    type: 'Crime',
    hours: 1,
    director: 'Steven Knight',
    stars: 5,
    actors: [
      'Cillian Murphy',
      'Paul Anderson',
      'Helen McCrory',
      'Sophie Rundle',
      'Tom Hardy',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Money Heist',
    image: 'assets/images/money_heist.jpg',
    screenPreview: 'assets/images/money_heist.jpg',
    description:
        'An unusual group of robbers attempt to carry out the most perfect robbery '
        'in Spanish history - stealing 2.4 billion euros from the Royal Mint of Spain.',
    type: 'Thriller',
    hours: 1,
    director: 'Álex Pina',
    stars: 5,
    actors: [
      'Úrsula Corberó',
      'Álvaro Morte',
      'Itziar Ituño',
      'Pedro Alonso',
      'Alba Flores',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Squid Game',
    image: 'assets/images/squid_game.jpg',
    screenPreview: 'assets/images/squid_game.jpg',
    description:
        'Hundreds of cash-strapped players accept a strange invitation to compete '
        'in children\'s games for a tempting prize, but the stakes are deadly.',
    type: 'Thriller',
    hours: 1,
    director: 'Hwang Dong-hyuk',
    stars: 5,
    actors: [
      'Lee Jung-jae',
      'Park Hae-soo',
      'Wi Ha-jun',
      'Jung Ho-yeon',
      'O Yeong-su',
    ],
    dates: dates,
    seats: seats,
  ),
];

final tvShows = [
  Movie(
    name: 'The Office',
    image: 'assets/images/the_office.jpg',
    screenPreview: 'assets/images/the_office.jpg',
    description:
        'A mockumentary on a group of typical office workers, where the workday '
        'consists of ego clashes, inappropriate behavior, and tedium.',
    type: 'Comedy',
    hours: 1,
    director: 'Greg Daniels',
    stars: 5,
    actors: [
      'Steve Carell',
      'Rainn Wilson',
      'John Krasinski',
      'Jenna Fischer',
      'B.J. Novak',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Friends',
    image: 'assets/images/friends.jpg',
    screenPreview: 'assets/images/friends.jpg',
    description:
        'Follows the personal and professional lives of six twenty to thirty year-old '
        'friends living in Manhattan.',
    type: 'Comedy',
    hours: 1,
    director: 'David Crane',
    stars: 5,
    actors: [
      'Jennifer Aniston',
      'Courteney Cox',
      'Lisa Kudrow',
      'Matt LeBlanc',
      'Matthew Perry',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'Game of Thrones',
    image: 'assets/images/game_of_thrones.jpg',
    screenPreview: 'assets/images/game_of_thrones.jpg',
    description:
        'Nine noble families fight for control over the lands of Westeros, '
        'while an ancient enemy returns after being dormant for millennia.',
    type: 'Fantasy',
    hours: 1,
    director: 'David Benioff',
    stars: 5,
    actors: [
      'Emilia Clarke',
      'Peter Dinklage',
      'Kit Harington',
      'Lena Headey',
      'Sophie Turner',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'The Big Bang Theory',
    image: 'assets/images/big_bang_theory.jpg',
    screenPreview: 'assets/images/big_bang_theory.jpg',
    description:
        'A woman who moves into an apartment across the hall from two brilliant '
        'but socially awkward physicists shows them how little they know about life.',
    type: 'Comedy',
    hours: 1,
    director: 'Chuck Lorre',
    stars: 5,
    actors: [
      'Jim Parsons',
      'Johnny Galecki',
      'Kaley Cuoco',
      'Simon Helberg',
      'Kunal Nayyar',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'How I Met Your Mother',
    image: 'assets/images/how_i_met.jpg',
    screenPreview: 'assets/images/how_i_met.jpg',
    description:
        'A father recounts to his children - through a series of flashbacks - '
        'the journey he and his four best friends took leading up to him meeting their mother.',
    type: 'Comedy',
    hours: 1,
    director: 'Carter Bays',
    stars: 5,
    actors: [
      'Josh Radnor',
      'Jason Segel',
      'Neil Patrick Harris',
      'Cobie Smulders',
      'Alyson Hannigan',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'The Mandalorian',
    image: 'assets/images/brooklyn_99.jpg',
    screenPreview: 'assets/images/brooklyn_99.jpg',
    description:
        'The travels of a lone bounty hunter in the outer reaches of the galaxy, '
        'far from the authority of the New Republic.',
    type: 'Sci-Fi',
    hours: 1,
    director: 'Jon Favreau',
    stars: 5,
    actors: [
      'Pedro Pascal',
      'Carl Weathers',
      'Giancarlo Esposito',
      'Katee Sackhoff',
      'Emily Swallow',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'House of the Dragon',
    image: 'assets/images/modern_family.jpg',
    screenPreview: 'assets/images/modern_family.jpg',
    description:
        'An internal succession war within House Targaryen at the height of its power, '
        '172 years before the birth of Daenerys Targaryen.',
    type: 'Fantasy',
    hours: 1,
    director: 'Ryan Condal',
    stars: 5,
    actors: [
      'Paddy Considine',
      'Matt Smith',
      'Emma D\'Arcy',
      'Olivia Cooke',
      'Rhys Ifans',
    ],
    dates: dates,
    seats: seats,
  ),
  Movie(
    name: 'The Last of Us',
    image: 'assets/images/the_simpsons.jpg',
    screenPreview: 'assets/images/the_simpsons.jpg',
    description:
        'After a global pandemic destroys civilization, a hardened survivor takes charge '
        'of a 14-year-old girl who may be humanity\'s last hope.',
    type: 'Drama',
    hours: 1,
    director: 'Craig Mazin',
    stars: 5,
    actors: [
      'Pedro Pascal',
      'Bella Ramsey',
      'Anna Torv',
      'Gabriel Luna',
      'Merle Dandridge',
    ],
    dates: dates,
    seats: seats,
  ),
];
