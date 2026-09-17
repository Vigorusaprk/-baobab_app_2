-- Photos du jeu de démonstration (appliqué le 2026-09-17 sur wrutwzbtnquxigxetxfx).
--
-- Les commerces et les offres de démonstration portaient des images au hasard
-- (picsum) : un bateau pour une boutique de cosmétiques, une manette pour un
-- snack. Pour juger l'application, il faut des photos qui montrent ce que la
-- carte annonce. Chaque ligne a été choisie sur Unsplash d'après le nom du
-- commerce ou de l'offre ; les URL passent par images.unsplash.com, qui accepte
-- l'affichage direct (w= pour la largeur, q= pour la qualité).
--
-- Les offres sont visées par (nom, commerce) : deux séances d'un même film dans
-- le même cinéma partagent la même photo, ce qui est le résultat voulu.
--
-- À rejouer tel quel si la base est réinitialisée ; les vraies photos des
-- commerçants, déposées depuis l'espace commerçant, remplacent celles-ci.

update business set "bgImg" = 'https://images.unsplash.com/photo-1771293549382-62829fad8f2d?w=1200&q=80&auto=format&fit=crop' where name = 'Hôtel Memling';
update business set "bgImg" = 'https://images.unsplash.com/photo-1643804926339-e94f0a655185?w=1200&q=80&auto=format&fit=crop' where name = 'AutoPlus RDC';
update business set "bgImg" = 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1200&q=80&auto=format&fit=crop' where name = 'Congo Wheels';
update business set "bgImg" = 'https://images.unsplash.com/photo-1643142314913-0cf633d9bbb5?w=1200&q=80&auto=format&fit=crop' where name = 'Kin Auto Location';
update business set "bgImg" = 'https://images.unsplash.com/photo-1668890094751-6986d0ca9dfc?w=1200&q=80&auto=format&fit=crop' where name = 'Cine City Ngaliema';
update business set "bgImg" = 'https://images.unsplash.com/photo-1640127249305-793865c2efe1?w=1200&q=80&auto=format&fit=crop' where name = 'CineKin Gombe';
update business set "bgImg" = 'https://images.unsplash.com/photo-1691187861257-a56c4aa2d7fb?w=1200&q=80&auto=format&fit=crop' where name = 'Beauté Kin Cosmetics';
update business set "bgImg" = 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=1200&q=80&auto=format&fit=crop' where name = 'Espace Culturel Baobab';
update business set "bgImg" = 'https://images.unsplash.com/photo-1610970878459-a0e464d7592b?w=1200&q=80&auto=format&fit=crop' where name = 'Burger King Centre';
update business set "bgImg" = 'https://images.unsplash.com/photo-1758578484459-677bfbbd00f7?w=1200&q=80&auto=format&fit=crop' where name = 'Fast Gombe';
update business set "bgImg" = 'https://images.unsplash.com/photo-1670710029403-607db8eeec83?w=1200&q=80&auto=format&fit=crop' where name = 'Kin Snacks';
update business set "bgImg" = 'https://images.unsplash.com/photo-1647724394693-2c93af726785?w=1200&q=80&auto=format&fit=crop' where name = 'Poulet Express';
update business set "bgImg" = 'https://images.unsplash.com/photo-1567978208292-b99af9c68e18?w=1200&q=80&auto=format&fit=crop' where name = 'Fleuve Congo Hôtel';
update business set "bgImg" = 'https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=1200&q=80&auto=format&fit=crop' where name = 'Pullman Kinshasa Grand Hôtel';
update business set "bgImg" = 'https://images.unsplash.com/photo-1783343982687-4c169ab0cf23?w=1200&q=80&auto=format&fit=crop' where name = 'Zando — Marché Central';
update business set "bgImg" = 'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=1200&q=80&auto=format&fit=crop' where name = 'Zando Shopping Center';
update business set "bgImg" = 'https://images.unsplash.com/photo-1773620494293-e9e075dd48fd?w=1200&q=80&auto=format&fit=crop' where name = 'Chez Flore';
update business set "bgImg" = 'https://images.unsplash.com/photo-1665332195309-9d75071138f0?w=1200&q=80&auto=format&fit=crop' where name = 'Chez Tantine Marie';
update business set "bgImg" = 'https://images.unsplash.com/photo-1782072712633-18255860cf36?w=1200&q=80&auto=format&fit=crop' where name = 'La Terrasse du Fleuve';
update business set "bgImg" = 'https://images.unsplash.com/photo-1558030089-02acba3c214e?w=1200&q=80&auto=format&fit=crop' where name = 'Le Baobab Grill';
update business set "bgImg" = 'https://images.unsplash.com/photo-1580654842920-37b786f32bfc?w=1200&q=80&auto=format&fit=crop' where name = 'Le Gourmet Parisien';
update business set "bgImg" = 'https://images.unsplash.com/photo-1763048443535-1243379234e2?w=1200&q=80&auto=format&fit=crop' where name = 'Mama Africa Resto';
update business set "bgImg" = 'https://images.unsplash.com/photo-1667388969250-1c7220bf3f37?w=1200&q=80&auto=format&fit=crop' where name = 'Saveurs de Kin';
update business set "bgImg" = 'https://images.unsplash.com/photo-1553028826-f4804a6dba3b?w=1200&q=80&auto=format&fit=crop' where name = 'Silikin Village';
update business set "bgImg" = 'https://images.unsplash.com/photo-1644937891190-41e569954e0e?w=1200&q=80&auto=format&fit=crop' where name = 'Boutique Wenge Mode';
update business set "bgImg" = 'https://images.unsplash.com/photo-1665815844395-06f64f44b5e3?w=1200&q=80&auto=format&fit=crop' where name = 'Kin Fashion Store';
update business set "bgImg" = 'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?w=1200&q=80&auto=format&fit=crop' where name = 'Bien-etre Malebo';
update business set "bgImg" = 'https://images.unsplash.com/photo-1601747779082-77a8fe377ecc?w=1200&q=80&auto=format&fit=crop' where name = 'Spa Zen Kinshasa';
update business set "bgImg" = 'https://images.unsplash.com/photo-1715094313256-31859c8ef92e?w=1200&q=80&auto=format&fit=crop' where name = 'Chutes de la Lukaya Tours';
update business set "bgImg" = 'https://images.unsplash.com/photo-1761342615545-cc970eea273d?w=1200&q=80&auto=format&fit=crop' where name = 'Decouverte Fleuve Congo';
update business set "bgImg" = 'https://images.unsplash.com/photo-1577971132997-c10be9372519?w=1200&q=80&auto=format&fit=crop' where name = 'Kin Excursions';
update business set "bgImg" = 'https://images.unsplash.com/photo-1529947327457-8f5cb53bc1b6?w=1200&q=80&auto=format&fit=crop' where name = 'Africa Trips Kinshasa';
update business set "bgImg" = 'https://images.unsplash.com/photo-1578894381163-e72c17f2d45f?w=1200&q=80&auto=format&fit=crop' where name = 'Congo Voyages';
update offers set image_url = 'https://images.unsplash.com/photo-1623869675781-80aa31012a5a?w=800&q=80&auto=format&fit=crop' where name = 'Hyundai Accent' and business_id = (select id from business where name = 'AutoPlus RDC');
update offers set image_url = 'https://images.unsplash.com/photo-1768400554801-2002b63e0591?w=800&q=80&auto=format&fit=crop' where name = 'Toyota Hiace' and business_id = (select id from business where name = 'AutoPlus RDC');
update offers set image_url = 'https://images.unsplash.com/photo-1650530579355-7ad9d4766043?w=800&q=80&auto=format&fit=crop' where name = 'Toyota Land Cruiser' and business_id = (select id from business where name = 'AutoPlus RDC');
update offers set image_url = 'https://images.unsplash.com/photo-1597465598019-b95b8f771d2f?w=800&q=80&auto=format&fit=crop' where name = 'Honda CRF' and business_id = (select id from business where name = 'Congo Wheels');
update offers set image_url = 'https://images.unsplash.com/photo-1642004614576-877e9266828a?w=800&q=80&auto=format&fit=crop' where name = 'Nissan Patrol' and business_id = (select id from business where name = 'Congo Wheels');
update offers set image_url = 'https://images.unsplash.com/photo-1603094543704-64cdce2d2532?w=800&q=80&auto=format&fit=crop' where name = 'Toyota Prado' and business_id = (select id from business where name = 'Congo Wheels');
update offers set image_url = 'https://images.unsplash.com/photo-1776043669128-b6b1f73bd8dd?w=800&q=80&auto=format&fit=crop' where name = 'Toyota Corolla' and business_id = (select id from business where name = 'Kin Auto Location');
update offers set image_url = 'https://images.unsplash.com/photo-1631377875413-b1e3e660bfa2?w=800&q=80&auto=format&fit=crop' where name = 'Toyota Hilux' and business_id = (select id from business where name = 'Kin Auto Location');
update offers set image_url = 'https://images.unsplash.com/photo-1660725997223-efbedf3397fb?w=800&q=80&auto=format&fit=crop' where name = 'Yamaha XTZ' and business_id = (select id from business where name = 'Kin Auto Location');
update offers set image_url = 'https://images.unsplash.com/photo-1621795307430-3ff25aa08945?w=800&q=80&auto=format&fit=crop' where name = 'Séance : Dune' and business_id = (select id from business where name = 'Cine City Ngaliema');
update offers set image_url = 'https://images.unsplash.com/photo-1759352370603-eeb21e082e74?w=800&q=80&auto=format&fit=crop' where name = 'Séance : Le Roi Lion' and business_id = (select id from business where name = 'Cine City Ngaliema');
update offers set image_url = 'https://images.unsplash.com/photo-1617374128851-c84e37dc9f37?w=800&q=80&auto=format&fit=crop' where name = 'Séance : Dune' and business_id = (select id from business where name = 'CineKin Gombe');
update offers set image_url = 'https://images.unsplash.com/photo-1563994798191-617da9c79c50?w=800&q=80&auto=format&fit=crop' where name = 'Séance : Le Roi Lion' and business_id = (select id from business where name = 'CineKin Gombe');
update offers set image_url = 'https://images.unsplash.com/photo-1674620213535-9b2a2553ef40?w=800&q=80&auto=format&fit=crop' where name = 'Coffret découverte' and business_id = (select id from business where name = 'Beauté Kin Cosmetics');
update offers set image_url = 'https://images.unsplash.com/photo-1693004926638-d2e47d705229?w=800&q=80&auto=format&fit=crop' where name = 'Crème hydratante karité' and business_id = (select id from business where name = 'Beauté Kin Cosmetics');
update offers set image_url = 'https://images.unsplash.com/photo-1671493229066-f36e86b35841?w=800&q=80&auto=format&fit=crop' where name = 'Huile capillaire' and business_id = (select id from business where name = 'Beauté Kin Cosmetics');
update offers set image_url = 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&q=80&auto=format&fit=crop' where name = 'Concert Fally Ipupa' and business_id = (select id from business where name = 'Espace Culturel Baobab');
update offers set image_url = 'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=800&q=80&auto=format&fit=crop' where name = 'Soirée Jazz' and business_id = (select id from business where name = 'Espace Culturel Baobab');
update offers set image_url = 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80&auto=format&fit=crop' where name = 'Spectacle humour' and business_id = (select id from business where name = 'Espace Culturel Baobab');
update offers set image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80&auto=format&fit=crop' where name = 'Burger classique' and business_id = (select id from business where name = 'Fast Gombe');
update offers set image_url = 'https://images.unsplash.com/photo-1609530127564-bee93ebe1c9e?w=800&q=80&auto=format&fit=crop' where name = 'Frites cheddar' and business_id = (select id from business where name = 'Fast Gombe');
update offers set image_url = 'https://images.unsplash.com/photo-1734747643067-6d4e0f705a00?w=800&q=80&auto=format&fit=crop' where name = 'Milkshake vanille' and business_id = (select id from business where name = 'Fast Gombe');
update offers set image_url = 'https://images.unsplash.com/photo-1729087012223-4c75e3b99edb?w=800&q=80&auto=format&fit=crop' where name = 'Beignets sales' and business_id = (select id from business where name = 'Kin Snacks');
update offers set image_url = 'https://images.unsplash.com/photo-1703219342329-fce8488cf443?w=800&q=80&auto=format&fit=crop' where name = 'Sandwich poulet' and business_id = (select id from business where name = 'Kin Snacks');
update offers set image_url = 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=800&q=80&auto=format&fit=crop' where name = 'Poulet frit 4 pieces' and business_id = (select id from business where name = 'Poulet Express');
update offers set image_url = 'https://images.unsplash.com/photo-1696739696220-8d2e27465662?w=800&q=80&auto=format&fit=crop' where name = 'Soda 33cl' and business_id = (select id from business where name = 'Poulet Express');
update offers set image_url = 'https://images.unsplash.com/photo-1650939986300-ce9609921fa7?w=800&q=80&auto=format&fit=crop' where name = 'Wings epicees' and business_id = (select id from business where name = 'Poulet Express');
update offers set image_url = 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Standard' and business_id = (select id from business where name = 'Fleuve Congo Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1590490359683-658d3d23f972?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Vue Fleuve' and business_id = (select id from business where name = 'Fleuve Congo Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1631049307290-bb947b114627?w=800&q=80&auto=format&fit=crop' where name = 'Suite Junior' and business_id = (select id from business where name = 'Fleuve Congo Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1605346576608-92f1346b67d6?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Classique' and business_id = (select id from business where name = 'Hôtel Memling');
update offers set image_url = 'https://images.unsplash.com/photo-1697618009092-01b24159a55a?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Exécutive' and business_id = (select id from business where name = 'Hôtel Memling');
update offers set image_url = 'https://images.unsplash.com/photo-1590381105924-c72589b9ef3f?w=800&q=80&auto=format&fit=crop' where name = 'Suite Memling' and business_id = (select id from business where name = 'Hôtel Memling');
update offers set image_url = 'https://images.unsplash.com/photo-1729605411476-defbdab14c54?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Deluxe Piscine' and business_id = (select id from business where name = 'Pullman Kinshasa Grand Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80&auto=format&fit=crop' where name = 'Chambre Supérieure' and business_id = (select id from business where name = 'Pullman Kinshasa Grand Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1515362778563-6a8d0e44bc0b?w=800&q=80&auto=format&fit=crop' where name = 'Suite Présidentielle' and business_id = (select id from business where name = 'Pullman Kinshasa Grand Hôtel');
update offers set image_url = 'https://images.unsplash.com/photo-1574365569389-a10d488ca3fb?w=800&q=80&auto=format&fit=crop' where name = 'Sac en toile' and business_id = (select id from business where name = 'Zando — Marché Central');
update offers set image_url = 'https://images.unsplash.com/photo-1651761179569-4ba2aa054997?w=800&q=80&auto=format&fit=crop' where name = 'T-shirt coton' and business_id = (select id from business where name = 'Zando — Marché Central');
update offers set image_url = 'https://images.unsplash.com/photo-1630381260512-e3fe55c11973?w=800&q=80&auto=format&fit=crop' where name = 'Sac en toile' and business_id = (select id from business where name = 'Zando Shopping Center');
update offers set image_url = 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?w=800&q=80&auto=format&fit=crop' where name = 'T-shirt coton' and business_id = (select id from business where name = 'Zando Shopping Center');
update offers set image_url = 'https://images.unsplash.com/photo-1586765501019-cbe3973ef8fa?w=800&q=80&auto=format&fit=crop' where name = 'Chikwangue' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800&q=80&auto=format&fit=crop' where name = 'Fufu' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1594858967566-c23ed8a24e75?w=800&q=80&auto=format&fit=crop' where name = 'Jus de bissap' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1661939252817-ebb73304f4c7?w=800&q=80&auto=format&fit=crop' where name = 'Liboke de capitaine' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1535424921017-85119f91e5a1?w=800&q=80&auto=format&fit=crop' where name = 'Makayabu' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1747253255646-3bffa4565a7a?w=800&q=80&auto=format&fit=crop' where name = 'Ntaba grillée' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1673465580365-b96bef916770?w=800&q=80&auto=format&fit=crop' where name = 'Pondu na madesu' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1603496987351-f84a3ba5ec85?w=800&q=80&auto=format&fit=crop' where name = 'Poulet à la moambe' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800&q=80&auto=format&fit=crop' where name = 'Réservation de table' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1682530016814-6a1c1311cd6e?w=800&q=80&auto=format&fit=crop' where name = 'Tangawisi' and business_id = (select id from business where name = 'Chez Flore');
update offers set image_url = 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800&q=80&auto=format&fit=crop' where name = 'Chikwangue' and business_id = (select id from business where name = 'Chez Tantine Marie');
update offers set image_url = 'https://images.unsplash.com/photo-1718942899999-b3da4177ee2a?w=800&q=80&auto=format&fit=crop' where name = 'Liboke de poisson' and business_id = (select id from business where name = 'Chez Tantine Marie');
update offers set image_url = 'https://images.unsplash.com/photo-1663004940357-ffd554538824?w=800&q=80&auto=format&fit=crop' where name = 'Pondu' and business_id = (select id from business where name = 'Chez Tantine Marie');
update offers set image_url = 'https://images.unsplash.com/photo-1574966739987-65e38db0f7ce?w=800&q=80&auto=format&fit=crop' where name = 'Réservation de table' and business_id = (select id from business where name = 'Chez Tantine Marie');
update offers set image_url = 'https://images.unsplash.com/photo-1665401015549-712c0dc5ef85?w=800&q=80&auto=format&fit=crop' where name = 'Capitaine grille' and business_id = (select id from business where name = 'La Terrasse du Fleuve');
update offers set image_url = 'https://images.unsplash.com/photo-1645231286309-2beccdfae91c?w=800&q=80&auto=format&fit=crop' where name = 'Cocktail tropical' and business_id = (select id from business where name = 'La Terrasse du Fleuve');
update offers set image_url = 'https://images.unsplash.com/photo-1599458252573-56ae36120de1?w=800&q=80&auto=format&fit=crop' where name = 'Réservation de table' and business_id = (select id from business where name = 'La Terrasse du Fleuve');
update offers set image_url = 'https://images.unsplash.com/photo-1498507297833-5373e346b4e0?w=800&q=80&auto=format&fit=crop' where name = 'Salade de fruits' and business_id = (select id from business where name = 'La Terrasse du Fleuve');
update offers set image_url = 'https://images.unsplash.com/photo-1750190624608-57ceddba8d69?w=800&q=80&auto=format&fit=crop' where name = 'Grillade mixte' and business_id = (select id from business where name = 'Le Baobab Grill');
update offers set image_url = 'https://images.unsplash.com/photo-1650292390827-51240d74eb0a?w=800&q=80&auto=format&fit=crop' where name = 'Jus de gingembre' and business_id = (select id from business where name = 'Le Baobab Grill');
update offers set image_url = 'https://images.unsplash.com/photo-1608816042754-d69cb2271bea?w=800&q=80&auto=format&fit=crop' where name = 'Réservation de table' and business_id = (select id from business where name = 'Le Baobab Grill');
update offers set image_url = 'https://images.unsplash.com/photo-1623670640497-0f7fa2ee09bc?w=800&q=80&auto=format&fit=crop' where name = 'Tarte a la banane' and business_id = (select id from business where name = 'Le Baobab Grill');
update offers set image_url = 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=800&q=80&auto=format&fit=crop' where name = 'Burger Baobab' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1547584370-2cc98b8b8dc8?w=800&q=80&auto=format&fit=crop' where name = 'Cheeseburger' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80&auto=format&fit=crop' where name = 'Coca-Cola (33cl)' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1688978181542-87a886a16fbe?w=800&q=80&auto=format&fit=crop' where name = 'Frites maison' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1627662168223-7df99068099a?w=800&q=80&auto=format&fit=crop' where name = 'Nuggets de poulet (6 pièces)' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1764304733301-3a9f335f0c67?w=800&q=80&auto=format&fit=crop' where name = 'Poulet Moambe' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1562713682-cde79058b2b2?w=800&q=80&auto=format&fit=crop' where name = 'Réservation de table' and business_id = (select id from business where name = 'Le Gourmet Parisien');
update offers set image_url = 'https://images.unsplash.com/photo-1548704087-b11dab0fbec0?w=800&q=80&auto=format&fit=crop' where name = 'Ndakala frit' and business_id = (select id from business where name = 'Mama Africa Resto');
update offers set image_url = 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80&auto=format&fit=crop' where name = 'Riz saute' and business_id = (select id from business where name = 'Mama Africa Resto');
update offers set image_url = 'https://images.unsplash.com/photo-1632158929413-168599fffbf7?w=800&q=80&auto=format&fit=crop' where name = 'Brochettes mixtes' and business_id = (select id from business where name = 'Saveurs de Kin');
update offers set image_url = 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=800&q=80&auto=format&fit=crop' where name = 'Frites maison' and business_id = (select id from business where name = 'Saveurs de Kin');
update offers set image_url = 'https://images.unsplash.com/photo-1741026079488-f22297dc3036?w=800&q=80&auto=format&fit=crop' where name = 'Sombe' and business_id = (select id from business where name = 'Saveurs de Kin');
update offers set image_url = 'https://images.unsplash.com/photo-1676210134188-4c05dd172f89?w=800&q=80&auto=format&fit=crop' where name = 'Dépannage plomberie' and business_id = (select id from business where name = 'Silikin Village');
update offers set image_url = 'https://images.unsplash.com/photo-1740657254989-42fe9c3b8cce?w=800&q=80&auto=format&fit=crop' where name = 'Nettoyage appartement' and business_id = (select id from business where name = 'Silikin Village');
update offers set image_url = 'https://images.unsplash.com/photo-1678922098020-95700a892472?w=800&q=80&auto=format&fit=crop' where name = 'Sac en toile' and business_id = (select id from business where name = 'Boutique Wenge Mode');
update offers set image_url = 'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?w=800&q=80&auto=format&fit=crop' where name = 'T-shirt coton' and business_id = (select id from business where name = 'Boutique Wenge Mode');
update offers set image_url = 'https://images.unsplash.com/photo-1535981444082-2a5dc0548ef3?w=800&q=80&auto=format&fit=crop' where name = 'Sac en toile' and business_id = (select id from business where name = 'Kin Fashion Store');
update offers set image_url = 'https://images.unsplash.com/photo-1693443687750-611ad77f3aba?w=800&q=80&auto=format&fit=crop' where name = 'T-shirt coton' and business_id = (select id from business where name = 'Kin Fashion Store');
update offers set image_url = 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=800&q=80&auto=format&fit=crop' where name = 'Massage relaxant 60 min' and business_id = (select id from business where name = 'Bien-etre Malebo');
update offers set image_url = 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800&q=80&auto=format&fit=crop' where name = 'Soin du visage' and business_id = (select id from business where name = 'Bien-etre Malebo');
update offers set image_url = 'https://images.unsplash.com/photo-1519824145371-296894a0daa9?w=800&q=80&auto=format&fit=crop' where name = 'Massage relaxant 60 min' and business_id = (select id from business where name = 'Spa Zen Kinshasa');
update offers set image_url = 'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?w=800&q=80&auto=format&fit=crop' where name = 'Soin du visage' and business_id = (select id from business where name = 'Spa Zen Kinshasa');
update offers set image_url = 'https://images.unsplash.com/photo-1570742544137-3a469196c32b?w=800&q=80&auto=format&fit=crop' where name = 'Excursion guidée' and business_id = (select id from business where name = 'Chutes de la Lukaya Tours');
update offers set image_url = 'https://images.unsplash.com/photo-1739641375132-f1d7e748e813?w=800&q=80&auto=format&fit=crop' where name = 'Visite culturelle' and business_id = (select id from business where name = 'Chutes de la Lukaya Tours');
update offers set image_url = 'https://images.unsplash.com/photo-1518709594023-6eab9bab7b23?w=800&q=80&auto=format&fit=crop' where name = 'Excursion guidée' and business_id = (select id from business where name = 'Decouverte Fleuve Congo');
update offers set image_url = 'https://images.unsplash.com/photo-1707068226685-27a15039f19b?w=800&q=80&auto=format&fit=crop' where name = 'Visite culturelle' and business_id = (select id from business where name = 'Decouverte Fleuve Congo');
update offers set image_url = 'https://images.unsplash.com/photo-1571957493901-4cc77844597b?w=800&q=80&auto=format&fit=crop' where name = 'Excursion guidée' and business_id = (select id from business where name = 'Kin Excursions');
update offers set image_url = 'https://images.unsplash.com/photo-1603703841668-14236b2ae39a?w=800&q=80&auto=format&fit=crop' where name = 'Visite culturelle' and business_id = (select id from business where name = 'Kin Excursions');
update offers set image_url = 'https://images.unsplash.com/photo-1654355205410-30ca4ba0dc22?w=800&q=80&auto=format&fit=crop' where name = 'Séjour organisé 3 jours' and business_id = (select id from business where name = 'Africa Trips Kinshasa');
update offers set image_url = 'https://images.unsplash.com/photo-1715262437769-d5a52db0d1dd?w=800&q=80&auto=format&fit=crop' where name = 'Vol Kinshasa - Lubumbashi' and business_id = (select id from business where name = 'Africa Trips Kinshasa');
update offers set image_url = 'https://images.unsplash.com/photo-1654355268541-ba815c1cbf54?w=800&q=80&auto=format&fit=crop' where name = 'Séjour organisé 3 jours' and business_id = (select id from business where name = 'Congo Voyages');
update offers set image_url = 'https://images.unsplash.com/photo-1719472196370-1b7eda2cf61f?w=800&q=80&auto=format&fit=crop' where name = 'Vol Kinshasa - Lubumbashi' and business_id = (select id from business where name = 'Congo Voyages');
