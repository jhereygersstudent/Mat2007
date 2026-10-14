# ============================================================
# MAT2007 FINAL PROJECT (in R)
# Which Dutch supermarket is the cheapest, Nov 2022 - Oct 2026?

library(jsonlite)   # fromJSON() reads the price files (JSON format)
library(ggplot2)    # makes the two plots

# Named vector
chains <- c(ah = "Albert Heijn", jumbo = "Jumbo", lidl = "Lidl",
            plus = "Plus", aldi = "Aldi", dirk = "Dirk")

dir.create("data", showWarnings = FALSE)      # showWarnings = FALSE prevents an error if the folder already exists
dir.create("figures", showWarnings = FALSE)   # the folder already exists


# ------------------------------------------------------------
# 1. Download one price snapshot per month
# ------------------------------------------------------------
# The price file on GitHub is overwritten every day, but every old
# version has a code (a "commit"). With that code we can still
# download the file exactly as it was on that date.
# read.csv(text = "...") reads a table written directly in the script.
snaps <- read.csv(text = "
month,date,commit
2022-11,2022-11-06,d830dc8e280ec169975838799d8247cb2e9c37e3
2022-12,2022-12-01,1b8407e36f493405e0e9e081d25cad240f72d7f6
2023-01,2023-01-01,d5c594483c0c30f22f0af5a37da7ecce26f54438
2023-02,2023-02-01,82d8930f63f2266e35507f0426a628c810a97221
2023-03,2023-03-01,7ca3bd891e6a2eb2d3b62f8513f37e40b78b2f42
2023-04,2023-04-01,6d26ca5bb72c6acf359037bb4ef8a59a958f9d15
2023-05,2023-05-01,76030da51084dabaa6d0dc7a6c5647abdfe3767f
2023-06,2023-06-01,5857c66eb7a8ddcfa0a972b794ac244f44fed788
2023-07,2023-07-01,761e7c76fea069aa2d3cf0481aae33578310a96a
2023-08,2023-08-01,fc690fe82ef27fffd28d119cf971ca41c0e413bf
2023-09,2023-09-01,0718be708de07da5b47d3e18e45149e699b75bd9
2023-10,2023-10-01,6380b92abb948258fbd104d13d6ed6b99c790091
2023-11,2023-11-01,eb383873222158c677a56f4c75d593ee5c5e2aaa
2023-12,2023-12-01,8d6f8855c20a417b512e16a260d2fa5d940f42c2
2024-01,2024-01-01,2c2ec72af386b1067b54cb8ee76dd0a4bcae62ed
2024-02,2024-02-01,3c7fa61fa7ea14f65cc05edc3162e195e67b2a15
2024-03,2024-03-01,41e594a1c9a144423b267591ac55886561181b99
2024-04,2024-04-01,a74987dcd438ccbef55322e071780508c922cc3f
2024-05,2024-05-01,7f90b2aa5fff39d75f75532a982fbefe52b41014
2024-06,2024-06-01,d3245ea8d30b975edf4f7aa02a8a8694c0c2228b
2024-07,2024-07-02,299b9db7fdba5e9c538cf681f42d37309933a68d
2024-08,2024-08-01,43a2764e4816e61922a294aca368acec3d2ba822
2024-09,2024-09-01,1f378e9d967dc12f96d386948335f8b10c8f7508
2024-10,2024-10-01,40678527f94d93d21feffafd96db6771cee15422
2024-11,2024-11-02,11bab800487b0ab02c34edd37e1892c1ca5e2bdb
2024-12,2024-12-01,9ebc3db1dd1905345f1200a4f794bc27988ddb44
2025-01,2025-01-01,4f0053149708e26cffa888085970f6b15e270c3e
2025-02,2025-02-01,743fd93177da444f00117d82487838862c1e494d
2025-03,2025-03-03,862ed16a2913bf55f598b8a4bad6c1d922fb5c0c
2025-04,2025-04-02,9028b6c85f499f6686c19ca21ffffdca0c3315cb
2025-05,2025-05-04,281ee6704f758ae9727f17844de0ed22b842c818
2025-06,2025-06-05,f61bc9bcab7b3a4016dd149847773c54b45d4d0a
2025-07,2025-07-01,8b19a4099a330343e1f4593900d1a45816ffff60
2025-08,2025-08-01,f267d5c0d8d9d20c77bb9b93b4562eb773827975
2025-09,2025-09-01,33c41caffd5b1ba2be4fca10f24cb940f136f701
2025-10,2025-10-01,2c134270bfb08792450d40138abfc8002ff6565b
2025-11,2025-11-01,57e56918420051d1f5b7d621f60483f718817db7
2025-12,2025-12-01,4034020bceebf829b50004736c8df393442cf3d8
2026-01,2026-01-02,d0f761156082b524c2ca447ebf680c61d197fd3b
2026-02,2026-02-02,13e6e15de850cdfecc30cfa89fc1d6242ff6ebb7
2026-03,2026-03-02,0c76b51378ccbc3e3c7f38becd73e1a96fab019e
2026-04,2026-04-01,e5d89416ff1a9f3c4b2e04b0777f1f9170057791
2026-05,2026-05-01,de1474af91fc4b62fbeeaa3969ab6a749397a727
2026-06,2026-06-01,9153e0b11fef082a4b26a3bd8ae4f167f6d66dd7
2026-07,2026-07-01,4c3016b2254a8a450538fe08c930b2c5a92bb502
2026-08,2026-08-01,93d3faf493e73fc88dce590130528dbf8e92dde8
2026-09,2026-09-01,a6ca1cc66d37ef74f2e9d2f69dcd11a58e663112
2026-10,2026-10-01,45c711348a56111cc231b851be77a78d14f25f4b
")

for (i in 1:nrow(snaps)) {
  file <- paste0("data/", snaps$date[i], ".json")
  if (!file.exists(file)) {          # skip files already downloaded 
    url <- paste0("https://raw.githubusercontent.com/supermarkt/checkjebon/",
                  snaps$commit[i], "/data/supermarkets.json")
    download.file(url, file, mode = "wb")   # "wb" = write binary, so the file is not changed on Windows
  }
}


# ------------------------------------------------------------
# 2. Read all snapshots into one table
# ------------------------------------------------------------
# Each file contains, per chain, a list of products with
#   n = product name, p = price in euro, s = pack size ("1 l", "500 g")
# The function returns one data frame for one date.
read_snapshot <- function(date) {
  js <- fromJSON(paste0("data/", date, ".json"))
  rows <- list()                     # one data frame per chain, combined at the end
  for (k in 1:nrow(js)) {
    store <- js$n[k]
    products <- js$d[[k]]            # [[k]] takes the product table of chain k out of the list
    if (store %in% names(chains) && length(products) > 0 && nrow(products) > 0) {
      rows[[store]] <- data.frame(store = store, name = products$n,
                                  size = products$s, price = products$p)
    }
  }
  out <- do.call(rbind, rows)        # do.call(rbind, list) binds all data frames under each other
  out$date <- as.Date(date)
  out
}

# lapply() runs read_snapshot() for every date and returns a list of 48 tables
prices <- do.call(rbind, lapply(snaps$date, read_snapshot))
prices <- prices[!is.na(prices$price) & prices$price > 0, ]   # remove missing prices
prices$size[is.na(prices$size)] <- ""                        # missing size -> empty text
cat("Prices loaded:", nrow(prices), "\n")


# ------------------------------------------------------------
# 3. Read the pack size of each product
# ------------------------------------------------------------
# Pack sizes are written in many ways ("1 l", "6 x 200 ml",
# "zak 1,5 kilogram"). read_size() turns them into a number of
# grams (g), millilitres (ml) or pieces (st), so prices can be
# compared per kg, per litre or per piece.
# If the size field is empty, the product name is used ("Eieren 12 Stuks").
read_size <- function(size, name) {
  text <- tolower(ifelse(size == "", name, size))
  text <- gsub(",", ".", text)                                  # 1,5 -> 1.5
  # Regular expression: optional "6 x", then a number, then a unit
  pattern <- "(?:(\\d+)\\s*x\\s*)?(\\d+(?:\\.\\d+)?)\\s*(kilogram|kilo|kg|gram|gr|g|liter|l|milliliter|ml|cl|stuks|stuk|st|rollen|rol)\\b"
  # regexec() finds the pattern, regmatches() returns the matched parts:
  # m[[i]] = (whole match, times, number, unit) -> length 4 if found
  m <- regmatches(text, regexec(pattern, text, perl = TRUE))
  amount <- rep(NA, length(text))
  unit <- rep(NA, length(text))
  for (i in which(lengths(m) == 4)) {
    times  <- ifelse(m[[i]][2] == "", 1, as.numeric(m[[i]][2]))  # "6 x 200 ml" -> 6
    number <- as.numeric(m[[i]][3]) * times
    u <- m[[i]][4]
    if (u %in% c("kilogram", "kilo", "kg"))      { amount[i] <- number * 1000; unit[i] <- "g" }
    if (u %in% c("gram", "gr", "g"))             { amount[i] <- number;        unit[i] <- "g" }
    if (u %in% c("liter", "l"))                  { amount[i] <- number * 1000; unit[i] <- "ml" }
    if (u %in% c("milliliter", "ml"))            { amount[i] <- number;        unit[i] <- "ml" }
    if (u == "cl")                               { amount[i] <- number * 10;   unit[i] <- "ml" }
    if (u %in% c("stuks", "stuk", "st", "rollen", "rol")) { amount[i] <- number; unit[i] <- "st" }
  }
  data.frame(amount = amount, unit = unit)
}

# Every product appears many times (once per month), so we read each
# unique name + size only once
products <- unique(prices[, c("name", "size")])
products$id <- 1:nrow(products) 
products <- cbind(products, read_size(products$size, products$name))
prices <- merge(prices, products, by = c("name", "size"))   # adds id, amount and unit to every price


# ------------------------------------------------------------
# 4. The shopping basket (30 products)
# ------------------------------------------------------------
# One row per product:
#   pattern = text the product name must contain   (| means "or")
#   exclude = text the name must NOT contain        (e.g. no chocolate milk)
#   unit, min, max = allowed pack sizes             (e.g. 900-2000 ml)
#   qty = the amount we compare                     (e.g. 1000 ml of milk)
basket <- read.csv(text = '
item,pattern,exclude,unit,min,max,qty
Semi-skimmed milk (1 L),halfvolle melk,choco|koffie|lactose|houdba|langlekker|drink|poeder|baby|\\d\\s*x\\s*\\d|soja|haver|karne|kids,ml,900,2000,1000
Eggs (10),eieren,choco|paas|gekookt|gekleurd|salade|mie|noodle|pasta|verf|kwartel|spek|vloeibaar|soep|wafel|koek|cake,st,6,12,10
Butter (250 g),^((ah|ah biologisch|de zaanse hoeve|zaanse hoeve|zuivelmeester|melkan|1 de beste|g.woon|gwoon|jumbo|plus|spar|coop|dekavers|campina|lidl|milbona|aldi|hoogvliet|vomar|poiesz|picnic|bio\\+|perkament|friesche vlag|biologische|verse|hollandse)\\s+)*(gezouten |ongezouten |hollandse )?roomboter( (gezouten|ongezouten|perkament|wikkel|goud|naturel|roomboter))*(\\s+\\d+\\s*g\\S*)?$,50%|botergoud|halfvolle,g,200,500,250
Young Gouda cheese (1 kg),\\b(jong belegen|jonge)\\b.*kaas|kaas.*\\b(jong belegen|jong)\\b|goudse jong,geit|komijn|kruiden|brandnetel|pesto|plakken|geraspt|blokjes|stick|snack|light|30\\+|20\\+|smeer|mini|burger|cracker|kip,g,300,1500,1000
Spaghetti (500 g),spaghetti,volkoren|saus|maaltijd|bolognese|tomaat|carbonara|kip|zalm|verse|vers|glutenvrij|spinazie|squash|groente|ijs|mix|pakket|kant,g,400,1000,500
White rice (1 kg),(witte rijst|langkorrel rijst|langgraan rijst|^rijst|\\brijst lang|basmati rijst|pandan rijst|surinaamse rijst),rijsttafel|kook|wafel|crackers|pap|melk|dessert|maaltijd|mix|nasi|bami|salade|azijn|olie|meel|noedel|vermicelli|risotto|sushi|bruine|volkoren|wilde|zilvervlies|kip|curry|groente|express|magnetron|pouch|snack|chips,g,400,2000,1000
Potatoes (1 kg),aardappelen|kruimige aardappel|vastkokende aardappel,schijfjes|partjes|frites|patat|gekookt|puree|salade|kroket|rosti|chips|krieltjes|zoete|gebakken|ovenschotel|stamppot|soep|kruiden|wedges|gratin|mix|parisienne|blokjes|roomboter|krielen|schotel|poffers,g,1000,5000,1000
Onions (1 kg),^(?!.*(rode|lente|zilver|sjalot|gebakken|gesnipperd|gedroogd|soep|ring|chips|crispy|marm|puree|gebrokkeld)).*\\buien\\b,rode|lente|zilver|sjalot|gebakken|gesnipperd|gedroogd|soep|ring|chips|crispy|marmelade|poeder|knoflook|mix|gesneden|ingemaakt|zuur|tafel|augurk,g,500,3000,1000
Carrots (1 kg),\\bwortelen\\b|\\bwortels\\b|winterpeen|\\bpeen\\b,julienne|geraspt|blokjes|rasp|salade|soep|sap|cake|taart|baby|mix|erwten|doperwten|puree|gesneden|hutspot|stamppot|schijfjes|reepjes|bospeen|chips|gekookt|pot|blik|sticks|snack|paars|regenboog|mini,g,500,3000,1000
Apples (1 kg),elstar|jonagold|\\bappels\\b|goudre|granny smith|pink lady|kanzi,aardappel|moes|sap|taart|flap|chips|cider|stroop|azijn|thee|gebak|crumble|gedroogd|ringen|parten|stukjes|snack|mini|kids|limonade|siroop|smoothie|kaneel|wafel,g,500,3000,1000
Bananas (1 kg),bananen|banaan,slurp|servero|whey|nutrition|plakjes|zakje|toetje|abrikoos|aardbei|knijpfruit|chips|gedroogd|smoothie|brood|yoghurt|snoep|shake|melk|ijs|cake|baby|knijp|puree|pure|vruchten|drank|kwark|muffin|mini|plantain|bak,g,500,2500,1000
Minced meat (500 g),half om half gehakt|half-om-half gehakt|h-o-h gehakt|gemengd gehakt|rundergehakt|^gehakt\\b,bal|balletjes|vegan|vegetar|plant|soja|kip|kalkoen|lam|maaltijd|lasagne|schotel|gekruid|kruiden|saus|kookpakket|burger|mix|slavink|ovenschotel|rollade|pasta|wrap|taco|chili|biologisch,g,250,1500,500
Chicken breast (500 g),kipfilet|kippenfilet|kippenborst,roasted|roosterz|met | en |krieltjes|sensatie|roerbak|pepersaus|spinazie|wortel|erwt|pasta|boursin|daily chef|vleeswaren|beleg|plakken|gerookt|gegrild|reepjes|blokjes|shoarma|saté|sate|gemarineerd|crispy|krokant|paneer|schnitzel|nugget|cordon|spies|vegan|vegetar|maaltijd|wrap|salade|smeerbaar|pulled|tandoori|kebab|curry|tikka|kruiden|burger|gyros|soep|snack|teriyaki|honing|knoflook|paprika|mexican|piri|bbq|cajun|gekookt|sous|stukjes|gesneden|kaas|spek|biologisch|dijen|haas|worst|ham|rollade|lasagne|ovenschotel,g,250,2000,500
Peanut butter (350 g),pindakaas,koek|reep|choco|ijs|saus|cups|bar|repen|snack|cake|cookie|wafel|crackers|popcorn|smoothie|eiwit|sport|protein|shake|mueslibar|ontbijtkoek|drop|bonbon|candy|sesam|stuk|knijp|poeder|stokjes|spread,g,250,1000,350
Chocolate sprinkles (400 g),hagelslag,ijs|taart|koek|cake|reep|snoep|muesli|cereal|puur.*mini|mini|vlokken|vla|vruchten|anijs|kleur|gekleurd|feest|confetti|wafel|kids|kinder|disney,g,200,800,400
Ground coffee (500 g),(snelfilter|filterkoffie|gemalen koffie|koffie.*gemalen|roodmerk|aroma rood|filter maling),cafe\\S*nevrij|decaf|pad|cups|capsule|bonen|instant|oplos|melk|creamer|filter(zakjes|papier|s\\b)|koffiefilter|machine|koek|ijs|cold|latte|cappuccino|espresso,g,250,1000,500
Black tea (20 bags),(zwarte thee|thee.*(engelse|english|earl grey|ceylon|melange)|earl grey|engelse melange|english breakfast),variatie|treats|box|ijs|ice|groene|groen|kruiden|rooibos|munt|gember|citroen|perzik|bosvruchten|framboos|fruit|chai|matcha|poeder|siroop|koek|beker|glas|mix|assortiment|cadeau,st,10,100,20
Oats (500 g),havermout|haverv?lokken,ontbijt|reep|koek|pap|drink|melk|mix|cookie|muesli|granola|cruesli|bar|choco|fruit|appel|banaan|kaneel|honing|bessen|instant|cups|beker|baby|zakjes|portie|glutenvrij|bio|overnight|porridge,g,400,1500,500
Sugar (1 kg),^(?!.*(riet|basterd|poeder|vanille|kandij|parel|gelei|klont|tablet|stevia|sticks|kaneel|ijs|bruine|donker|zoetstof|vrij|light|kokos|agave|druiven|appel|siroop|stroop|wafel|brood|meel|koek|snoep|spin|mint)).*\\b(kristalsuiker|suiker|witte suiker|fijne suiker|fijne kristalsuiker)\\b,riet|basterd|poeder|vanille|kandij|parel|gelei|klont|tablet|stevia|sticks|kaneel|ijs|bruin|donker|zoetstof|vrij|light|kokos|agave|siroop|stroop|wafel|brood|koek|snoep|zero|minder|0%|ontbijt|cereal|popcorn|chips|thee|koffie|drank|sap|cola|limonade|frisdrank|vla|yoghurt|kwark|melk,g,500,2000,1000
Flour (1 kg),tarwebloem|^bloem\\b|patentbloem|\\bbloem\\b,volkoren|zelfrijzend|pannenkoek|poffertjes|mais|rijst|kokos|amandel|spelt|rogge|boekweit|glutenvrij|mix|brood|wafel|koek|cake|pizza|bakmix|beslag|taart|zak.*kruiden|kruiden|bloemkool|bloemen|bloembollen|plant|zaad|bloemenmix|thee|honing|siroop|zout|sap|potgrond|vaas|tulp|roos|vergeet|zonnebloem,g,500,2500,1000
Sunflower oil (1 L),zonnebloemolie,mayo|fritessaus|tonijn|sardines|chips|zalm|ansjovis|makreel|spray|margarine|halvarine|olijf|mix|saus|dressing|zeep|zout|kruiden|pesto|knoflook|vis|haring|zeeppoeder|cracker|noten,ml,500,3000,1000
Passata (500 g),passata|gezeefde tomaten,basil|pizza|chips|tomatenpuree|kruiden|knoflook|ui|olijf|groente|mix|soep|grove|stukjes|bio,g,400,1000,500
Canned kidney beans (400 g),bruine bonen,soep|schotel|chili|saus|maaltijd|mix|salade|spek|vegan|burger|chips|kruiden|tomatensaus|curry|vegetar|stazak|pot.*\\b(720|680|700)\\b,g,300,900,400
Peas in jar or can (680 g),doperwten,wortel|worteltjes|soep|mais|maïs|mix|salade|chips|snack|gedroogd|pasta|hummus|rijst|wasabi|eiwit|groente|sperzie|bonen|peultjes|zuur|erwtensoep|chili|curry|diepvries|ijs,g,300,1000,680
Yoghurt (1 L),(halfvolle|magere|volle) yoghurt,griekse|turkse|drink|fruit|aardbei|vanille|perzik|kers|framboos|bosvruchten|mango|honing|stracciatella|muesli|granola|kids|knijp|baby|soja|kokos|haver|lactose|0%|light|pot.*(125|150|175|200)|beker|choco|dessert|kwark|skyr|limoen|citroen|bio|biologisch|mini|ijs|saus|dressing|bekertje|cups,ml,500,1500,1000
Orange juice (1 L),sinaasappelsap|jus d.orange,vruchtvlees|\\bappel|mango|multi|aardbei|ananas|pompelmoes|perzik|wortel|siroop|limonade|ranja|light|zero|0%|minder|drink|smoothie|pakje|kids|mini|ijs|vers|geperst|blik|kers|framboos|vitamine|\\d\\s*x\\s*\\d,ml,900,2000,1000
Cola (1.5 L),\\bcola\\b,zero|light|vanille|cherry|lemon|lime|citroen|kers|0%|suikervrij|zonder|caffeine|cafeine|ijs|snoep|flesjes|blik|snoepjes|zuur|mix|whisky|rum|bacardi|jack|vodka|baco|smaak|candy|chips|kaneel|dop|pakket|mini|klein|sticker|pack|x\\s*\\d|stevia|max|energy,ml,1000,2000,1500
Crisps paprika (200 g),chips.*paprika|paprika.*chips,ham|kaas|zout|naturel|mais|tortilla|kip|groente|pita|wraps|ribbel|light|mini|saus|vega|pak.*x|multipack|bak|kruiden.*mix|mix|mini|mexi|bbq|chili|pittig|crackers|smaak|sweet,g,150,300,200
Toilet paper (12 rolls),toiletpapier|wc papier|wc-papier|closetpapier,gevoelige|nat|vochtig|reinig|verfris|keukenrol|blok|tissue|zakdoek|reis|mini|travel|spray|borstel,st,6,24,12
Dishwashing liquid (500 ml),afwasmiddel,vaatwas|machine|tablet|tabs|caps|poeder|zeep.*hand|navul|refill|schuim|borstel|spons|doek|gel.*vaat|glans|spoel|zout|reiniger|ontkalker|allesreiniger,ml,400,1500,500
')
basket$exclude[is.na(basket$exclude)] <- ""   # empty exclude -> exclude nothing


# ------------------------------------------------------------
# 5. Cheapest matching product per item, chain and month
# ------------------------------------------------------------
# Find list of unique products (fast), then take all prices
# of the products that match.
name <- tolower(products$name)
basket_prices <- data.frame()
for (i in 1:nrow(basket)) {
  item <- basket[i, ]
  match <- grepl(item$pattern, name, perl = TRUE) &                  # right name
           !(item$exclude != "" & grepl(item$exclude, name, perl = TRUE)) &  # no wrong words
           products$unit %in% item$unit &                            # right unit
           products$amount >= item$min & products$amount <= item$max # right pack size
  found <- prices[prices$id %in% products$id[which(match)], ]
  found$cost <- found$price / found$amount * item$qty            # price for the basket amount
  # aggregate(cost ~ store + date, FUN = min) keeps the lowest cost
  # for every combination of chain and month
  cheapest <- aggregate(cost ~ store + date, data = found, FUN = min)
  cheapest$item <- item$item
  basket_prices <- rbind(basket_prices, cheapest)
}


# ------------------------------------------------------------
# 6. Compare the chains
# ------------------------------------------------------------
# For each item and month divide each chain's price by the median
# price of the chains that month: ratio 1.10 = 10% more expensive than
# a typical chain.
# ave(x, group1, group2, FUN) computes FUN per group and returns a value
# for every row (unlike aggregate(), which returns one row per group).
basket_prices$median <- ave(basket_prices$cost, basket_prices$item, basket_prices$date, FUN = median)
basket_prices$ratio  <- basket_prices$cost / basket_prices$median
basket_prices <- basket_prices[basket_prices$ratio > 0.4 & basket_prices$ratio < 2.5, ]  # get rid of wrong matches

# Price index of a chain in a month = average ratio over all items it sells.
index <- aggregate(ratio ~ store + date, data = basket_prices, FUN = mean)
items <- aggregate(ratio ~ store + date, data = basket_prices, FUN = length)
index$items <- items$ratio
index <- index[index$items >= 20, ]        # need at least 20 of the 30 items, else the index is unreliable

# Basket cost in euro = cost of the typical basket that month x the chain's price index
typical <- aggregate(median ~ date, data = unique(basket_prices[, c("item", "date", "median")]), FUN = sum)
index <- merge(index, typical, by = "date")
index$basket <- index$ratio * index$median


# ------------------------------------------------------------
# 7. Fill missing months so every line is complete
# ------------------------------------------------------------
# Some months a chain has no usable data (e.g. checkjebon could not
# read its website). Then we use the value of the month before
# Each chain starts at its first month with data (Lidl only from December 2025).
all_months <- as.Date(snaps$date)
filled <- data.frame()
for (s in names(chains)) {
  x <- index[index$store == s, ]
  last_value <- NA
  for (d in all_months[all_months >= min(x$date)]) {
    if (any(x$date == d)) last_value <- x$basket[x$date == d]   # new value if there is data, else keep the old one
    # the for-loop turns dates into numbers, as.Date(..., origin) turns them back
    filled <- rbind(filled, data.frame(store = s, date = as.Date(d, origin = "1970-01-01"),
                                       basket = last_value))
  }
}
filled$chain <- chains[filled$store]   # short name -> full name, e.g. "ah" -> "Albert Heijn"

# % above/below the average of the chains that month, and rank (1 = cheapest)
filled$vs_avg <- 100 * (filled$basket / ave(filled$basket, filled$date, FUN = mean) - 1)
filled$rank   <- ave(filled$basket, filled$date, FUN = rank)
write.csv(filled, "basket_per_chain_per_month.csv", row.names = FALSE)   # all numbers behind the plots


# ------------------------------------------------------------
# 8. Results per chain
# ------------------------------------------------------------
# median          = the typical month (% vs average)
# low, high       = middle 50% of months (25th and 75th percentile)
# months_cheapest = number of months with rank 1
summary <- data.frame()
for (ch in unique(filled$chain)) {
  x <- filled[filled$chain == ch, ]
  summary <- rbind(summary, data.frame(
    chain           = ch,
    median          = median(x$vs_avg),
    low             = quantile(x$vs_avg, 0.25),
    high            = quantile(x$vs_avg, 0.75),
    months_cheapest = sum(x$rank == 1),
    months          = nrow(x)))
}
summary <- summary[order(summary$median), ]   # sort from cheapest to most expensive
cat("\nPrice compared with the average of the six chains (%), and months cheapest:\n")
print(summary, row.names = FALSE, digits = 3)


# ------------------------------------------------------------
# 9. Plot 1: basket cost over time
# ------------------------------------------------------------
# One line per chain; colours to  match each chain's logo.
colours <- c("Albert Heijn" = "#00a0e2", "Jumbo" = "#e6b800", "Lidl" = "#1f3fbf",
             "Plus" = "#e4007c", "Aldi" = "#2e8b57", "Dirk" = "#d62728")
plot1 <- ggplot(filled, aes(x = date, y = basket, colour = chain)) +
  geom_line(linewidth = 1) +            # one line per chain (colour = chain)
  scale_colour_manual(values = colours) +
  labs(title = "Price of shopping basket at six biggest Dutch supermarkets",
       x = NULL, y = "Basket cost (euro)", colour = NULL) +
  theme_minimal()
# width/height in inches; bg = "white" so the PNG has no transparent background
ggsave("figures/plot1_basket_over_time.png", plot1, width = 10, height = 5.5, bg = "white")


# ------------------------------------------------------------
# 10. Plot 2: ranking over all months
# ------------------------------------------------------------
# Grey dot = one month, big dot = median month, bar = middle 50% of
# months. Green = cheaper than average, orange = more expensive.
# Chains are sorted from cheapest (top) to most expensive (bottom).
summary$label <- paste0(summary$chain, "  (cheapest in ", summary$months_cheapest,
                        " of ", summary$months, " months)")
filled$label  <- summary$label[match(filled$chain, summary$chain)]
order_labels  <- rev(summary$label)                    # cheapest at the top
# factor(..., levels) fixes the order of the chains on the y-axis
summary$label <- factor(summary$label, levels = order_labels)
filled$label  <- factor(filled$label,  levels = order_labels)
summary$cheaper <- summary$median < 0

plot2 <- ggplot() +
  geom_vline(xintercept = 0, colour = "grey30") +   # vertical line at the average (0%)
  geom_jitter(data = filled, aes(x = vs_avg, y = label, shape = "One month"),
              height = 0.15, width = 0, colour = "grey45", alpha = 0.35, size = 1.3) +   # jitter: small random up/down shift so dots don't overlap
  geom_segment(data = summary, aes(x = low, xend = high, y = label, yend = label,
                                   colour = cheaper, linetype = "Middle 50% of months"),
               linewidth = 3, alpha = 0.5) +
  geom_point(data = summary, aes(x = median, y = label, colour = cheaper, shape = "Median month"), size = 4) +
  geom_text(data = summary, aes(x = median, y = label, label = sprintf("%+.1f%%", median)),
            vjust = -1.2, size = 3.2) +
  scale_colour_manual(values = c("TRUE" = "#1baf7a", "FALSE" = "#eb6834"), guide = "none") +
  # The legend explains the three kinds of marks (shown in grey);
  # override.aes changes how the marks look in the legend only
  scale_shape_manual(name = NULL, values = c("One month" = 16, "Median month" = 16),
                     breaks = c("One month", "Median month"),
                     guide = guide_legend(override.aes = list(size = c(1.5, 4), alpha = c(0.35, 1),
                                                              colour = c("grey45", "grey30")))) +
  scale_linetype_manual(name = NULL, values = c("Middle 50% of months" = "solid"),
                        guide = guide_legend(override.aes = list(linewidth = 3, alpha = 0.5, colour = "grey50"))) +
  labs(title = "Shopping basket prices per month",
       x = "Basket price compared with the average of the six chains that month (%)", y = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")
ggsave("figures/plot2_ranking.png", plot2, width = 10, height = 5.5, bg = "white")

print(plot1)   # also show both plots on screen (in VS Code: the Plots pane)
print(plot2)
