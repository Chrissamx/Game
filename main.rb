require 'sinatra'
require 'spreadsheet'
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'admin' and password == 'admin'
end
$allplayers   = Array.new(20) {Array.new(4)}
$instructions =Array.new(200) {Array.new(11)}
$myArray      =Array.new(2)
$nplayers     = 0
$items        = 0
$clothing     = 0
$fstr         = 0
$fbi          = 0
$mstr         = 0
$mbi          = 0
$fplay        = 0
$mplay        = 0
$randplayer2  = 0
$randplayer1  = 0
$randplayer3  = 0
$lastplayer   = 99
$randinstr    = 0
$instr        = " "
$itemsstr     = " "
$fplays       = " "
$randname     = " "
$goodplayer   = false
$start        = 'yes'
$counter      = 0
$row          = 0
$coll         = 0
$itemsfactor  = 3.50
$mostitems    = 0
$range        = 10
$rangestart   = 1
$space        = " "
$numbercheck  = "  "
$nmales       = 0
$fmales       = 0
$check3       = 'no'
$instr3       = ' '
$changed      = 0
$clothingcount = 0.00
$myArray[1]   ='X'
$minstr       = 0
$finstr       = 0
$Totalplays   = 0
$donecount    = 0
$plus         = 1.6
$rows         = 0
$checkzero    = 0
$timeseconds  = 0

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open 'instr.xls'
  sheet = book.worksheet 0
  if $start == 'yes'
    loop do
      sheet.rows[$counter][9] = "Y"
      $counter = $counter + 1
      if sheet.rows[$counter][0] =="END"
        book.write 'instr.xls'
        $start = 'No'      
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
 if $row == $counter
   break
 end
end

def splits
  $myArray        = $instr.split("//")
  if $myArray[0] == $instr
    $myArray[1]   = "X"
    $timeseconds  = ($instructions[$randinstr][8]).to_i 
  else
    $timeseconds  = 0
  end
end

def addplayer
  $allplayers[$nplayers][0],$allplayers[$nplayers][1],$allplayers[$nplayers][2],$allplayers[$nplayers][3] = 
  params[:name],params[:Sex],params[:Preference],params[:Clothing].to_i
  $itemsstr   = $allplayers[$nplayers][3]
  $items      = $items + $itemsstr.to_i
  $nplayers   = $nplayers + 1 
  $itemfactor = $items / $nplayers
  if params[:Sex] == "M"
    $nmales     = $nmales + 1
  end
  if params[:Sex] == "F"
    $fmales     = $fmales + 1
  end
  redirect '/game'
end

def checkclothing
  $mostitems  = 0
  loopcount   = 0
  count       = 0
  row         = 0
  playercount = 0
  player      = ' ' 
  options     = 5
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
        if loopcount > 10
          options  = rand(0..options)
          case options
          when 0
         $instr    = player + " remove an item of clothing"
          when 1
            $instr = player + " first player of oposite sex to your right to help you remove item of clothing" 
          when 2
            $instr = player + " remove an item of clothing"
          when 3
            $instr = player + " choose a player to remove item of your clothing of YOUR choice" 
          when 4
            $instr = player + " choose a player to remove item of your clothing of THEIR choice"
          when 5
            $instr = player + " players will vote to determine who will remove an item of your clothing" 
          else
            $instr = player + " players will vote to determine who will remove an item of your clothing" 
          end 
         $allplayers[playercount][3] = $allplayers[playercount][3] - 1
         $items    = $items - 1
         $timeseconds = 0
         $instructions[$randinstr][8] = 0
         $instructions[$randinstr][9] = "Y"
         if $items <= 0
          itemszero
         end
         break
       end     
    end
  end
 end
 $itemsfactor      = $itemsfactor - 0.06
end

def itemszero
  $rows = 0 
 loop do
    if $instructions[$rows][0]     == 'Y'
      $checkzero = 1
       $instructions[$rows][9]      = 'X'
    end
    $rows                           = $rows + 1
    if $rows == $counter
     break
    end
 end
end

def checktotalclothing
  nothing       = 0
  $clothingcount = ($items / $nplayers)
  if $clothingcount >= 4.5
    $instr = "Everyone remove two items of clothing" 
    $items = $items - $nplayers * 2
    $itemsfactor = $itemsfactor - 1.6
    $instructions[$randinstr][9] = "Y"
    $Totalplays = $Totalplays - 1
    splits
    redirect '/play'
  else  
     if $clothingcount >= 3.5
    $instr = "Everyone to remove an item of clothing" 
    $items = $items - $nplayers
    $itemsfactor = $itemsfactor - 0.8
    $instructions[$randinstr][9] = "Y"
    $Totalplays = $Totalplays - 1
    splits
    redirect '/play'
   end
  end
end

def randomplayer1
  loop do
   $randplayer1     = rand(0...$nplayers)
   if $randplayer1 != $lastplayer
      $lastplayer   = $randplayer1
     break
   end
  end
end

def randomplayer2
 loop do
   $randplayer2 = rand(0...$nplayers)
     if $randplayer2 != $randplayer1
       if $allplayers [$randplayer2][1]         == 'F'
         if $allplayers [$randplayer2][2]       == 'B'
           if $allplayers [$randplayer1][1]     == 'F'
             if $allplayers [$randplayer1][2]   == 'B'
               if $instructions [$randinstr][6] != 'M'
                 break
                end
             end
            end
          end
         if $allplayers [$randplayer1][1]       == 'M'
           break
         end
        end
        if $allplayers [$randplayer2][1]        == 'M'
          if $allplayers [$randplayer1][1]      == 'F'
            break
          end
        end
      end
  end 
end

def randomplayer3
  loops = 0
  if (($instructions[$randinstr][3]).to_i) == 3
  loop do
    loops = loops + 1
    counter                               = 0
    $randplayer3                          = rand(0...$nplayers)
    if $randomplayer3                    != $randplayer1
        counter                           = 1
    end
    if $randplayer3                      != $randplayer2
        counter                           = counter + 1
    end
    if counter                           == 2
      if $allplayers [$randplayer1][1]   == 'F'
        if $allplayers [$randplayer3][1] == 'M'
           break
        end
      end
      if $allplayers [$randplayer1][1]   == 'M'
        if $allplayers [$randplayer3][1] == 'F'
           break
        end
      end
   end
    if loops > 100
       break
    end
  end
 end
end

def splitinst
  if $myArray[1] != "X"
     $myArray[0]  = $myArray[1]
     $myArray[1]  = "X"
     $timeseconds = ($instructions[$randinstr][8]).to_i 
    redirect '/play'
  end
end

def timecheck 
  if (($instructions[$randinstr][8]).to_i) == 0
   redirect '/play'
  end
end

def players
  if $nmales < 1
    redirect '/game'
  end
  if $fmales < 1
    redirect '/game'
  end
  if $donecount == 0
  if $nmales == 1 
    $row      = 1
    loop do
       if (($instructions[$row][3]).to_i)  == 3
         if ($instructions[$row][5])       == 'F'
           $instructions[$row][9]           = 'X'
           $minstr = $minstr + 1
         end
       end
        $row = $row + 1
        if $row == $counter
          $donecount = 1
          $plus = 2
          break
        end
     end
  end
  end
  if $donecount <= 1
    if $fmales == 1 
    $row      = 1
    loop do
     if (($instructions[$row][3]).to_i)   == 3
      if ($instructions[$row][5])         == 'M'
        $instructions[$row][9]             = 'X'
        $finstr = $finstr + 1
      end
    end
    $row = $row + 1
    if $row == $counter
      $donecount = $donecount + 1
      $plus = 2
      break
    end
  end
end
 end
end

def randominstr
  loop do
      $randinstr = rand($rangestart..$range)
      $instr3    = $instructions[$randinstr][3]
      $instr     = $instructions[$randinstr][10]
      if $allplayers [$randplayer1][1]    == 'F'
       if $instructions[$randinstr][5]    != 'M'
         if $instructions[$randinstr][9]  == 'Y'
           $instructions[$randinstr][9]    = 'X'
           if $range     < $counter
             $range      = $range + $plus
             $rangestart = $rangestart 
           else
            $range       = $counter
           end
           $Totalplays   = $Totalplays + 1
           break
         end
       end
     end
     if $allplayers [$randplayer1][1]     == 'M'
       if $instructions[$randinstr][5]    != 'F'
         if $instructions[$randinstr][9]  == 'Y'
           $instructions[$randinstr][9]    = 'X'
           if $range     < $counter
             $range      = $range + $plus
             $rangestart = $rangestart + 1
           else
            $range       = $counter
           end
           $Totalplays   = $Totalplays + 1
           break
         end
       end
     end
   end
 end

def getrandom
  splitinst
  randomplayer1  
  randominstr
  randomplayer2
  randomplayer3 
  checktotalclothing
  checkclothing
  splits
  redirect '/play'
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
  players
  getrandom
  erb :games
end

get '/timer' do
  timecheck
  erb :timer
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
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ice Breaker</title>
  <style>
h1 {font-size: 60px;}
h1 {text-align: center;}
p {text-align: center;}
div {text-align: center;}
</style>
</head>
<body style="background-color:powderblue;">
  <p><h1><b>Ice Breaker</b></h1></p>
    <nav>
      <p><h1><a href="/game" title="Game" >game</a></h1></p>
        </nav>
      <section>
      <p align="center"><a href="/exit"><button style="font-size: 32px;">quit</button></a><p></p>
      </section>
    </body>
    </html>     