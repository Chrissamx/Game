require 'sinatra'

require 'spreadsheet'



$allplayers =Array.new(20) {Array.new(4)}
$instructions =Array.new(100) {Array.new(11)}
$nplayers = 0
$items = 0
$clothing = 0
$fstr  = 0
$fbi   = 0
$mstr  = 0
$mbi   = 0
$fplay = 0
$mplay = 0
$randplayer2 = 0
$randplayer1 = 0
$randplayer3 = 0
$lastplayer = 99
$randinstr = 0
$instr = " "
$itemsstr = " "
$fplays = " "
$randname =" "
$goodplayer = false
$start = 'yes'
$counter = 0
$row = 0
$coll = 0
$itemsfactor = 4
$mostitems = 0
$range = 10
$rangestart = 1
$space = " "

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open 'instr.xls'
  sheet = book.worksheet 0

  if $start == 'yes'
    loop do
      sheet.rows[$counter][9] = "Y"
      $counter = $counter + 1
      if $counter > 90
        book.write 'instr.xls'
        $start = 'No'
        $counter = 0
        break
      end
    end
  end

loop do
  loop do
   $instructions[$row][$coll] = sheet.rows[$row][$coll]
   $coll = $coll + 1
   if $coll > 11
    $coll = 0
    break
   end
  end
  $row = $row + 1
 if $row > 90
   break
 end
end

def addplayer
  $allplayers[$nplayers][0],$allplayers[$nplayers][1],$allplayers[$nplayers][2],$allplayers[$nplayers][3] = 
  params[:name],params[:Sex],params[:Preference],params[:Clothing].to_i
  $itemsstr   = $allplayers[$nplayers][3]
  $items      = $items + $itemsstr.to_i
  $nplayers   = $nplayers + 1 
  $itemfactor = $items / $nplayers
  redirect '/game'
end

def getrandom
  randomplayer1  
  randominstr
  randomplayer2
  randomplayer3
  checkclothing
  redirect '/play'
end

def checkclothing
  $mostitems  = 0
  loopcount   = 0
  count       = 0
  playercount = 0
  player      = ' ' 

 if $items >0
   if ($itemsfactor * $nplayers) < $items
    loop do
      count          = rand(0...$nplayers)
      loopcount      = loopcount + 1
      if $mostitems  < $allplayers[count][3]
         $mostitems  = $allplayers[count][3]
         player      = $allplayers[count][0]
         playercount = count
       end
        if loopcount > 50
         $instr = player + " remove an item of clothing"
         $allplayers[playercount][3] = $allplayers[playercount][3] - 1
         $items = $items - 1
         break
       end     
    end
   end
 end
 $itemsfactor = $itemsfactor - 0.1
end

def randomplayer1
  loop do
   $randplayer1     = rand(0...$nplayers)
   if $randplayer1 != $lastplayer
    $lastplayer     = $randplayer1
     break
   end
  end
end

def randomplayer2
 loop do
   $randplayer2 = rand(0...$nplayers)
     if $randplayer2 != $randplayer1
       if $allplayers [$randplayer2][1] == 'F'
         if $allplayers [$randplayer2][2] == 'B'
           if $allplayers [$randplayer1][1] == 'F'
             if $allplayers [$randplayer1][2] == 'B'
               if $instructions [$randinstr][6] != 'M'
                 break
                end
             end
            end
          end
         if $allplayers [$randplayer1][1] == 'M'
           break
         end
        end
        if $allplayers [$randplayer2][1] == 'M'
        if $allplayers [$randplayer1][1] == 'F'
        break
        end
      end
    end
  end 
end

def randomplayer3
  loop do
    $randplayer3     = rand(0...$nplayers)
    if $randplayer3  != $randplayer1
     if $randplayer3 != $randomplayer2
       break
     end
   end
 end
end
  
def randominstr
  loop do
  $randinstr = rand($rangestart..$range)
  $instr = $instructions[$randinstr][10]
  if $allplayers [$randplayer1][1] == 'F'
    if $instructions[$randinstr][5] != 'M'
     if $instructions[$randinstr][9] == 'Y'
         $instructions[$randinstr][9] = "X"
         if $range < 90
          $range = $range + 1
          $rangestart = $rangestart 
         end
         break
     end
    end
  end
  if $allplayers [$randplayer1][1] == 'M'
    if $instructions[$randinstr][5] != 'F'
     if $instructions[$randinstr][9] == 'Y'
         $instructions[$randinstr][9] = "X"
         if $range < 90
         $range = $range + 2
         $rangestart = $rangestart + 1
         end
         break
     end
    end
  end
end
end

def exitprog
  load "main.rb"
end

get '/' do
 erb :home
end

get '/players' do
  erb :players
end

post '/game' do
  addplayer
  erb :game
end

get '/game' do
  erb :game
end

get '/games' do 
  getrandom
  erb :games
end

get '/play' do 
  erb :play
end

get '/exit' do
  exitprog
end

__END__

@@home
<!doctype html>

<html lang="en">
<head>
  <title>Ice Breaker</title>
  <meta charset="utf-8">
</head>

<body style="background-color:powderblue;">
  <h1><p align="center" >Ice Breaker</p></h1>
    <nav>
      <h1><p align="center"><a href="/game" title="Game" align="center" style="font-size: 32px;">game</a></p></h1>
        </ul>
        </nav>
      </header>
      <section>
      </section>
    </body>
    </html>     