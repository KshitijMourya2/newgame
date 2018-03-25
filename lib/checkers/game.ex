defmodule Checkers.Game do

  #This function will assign the player to the game state
  def assignPlayer(game,playername) do
      IO.inspect('Inside assignPlayer')
      IO.inspect(playername)
      IO.inspect(game.player1)
      IO.inspect(game.player2)
      cond do
        game.player1 == "none" -> %{game | player1: playername }
        game.player2 == "none" -> %{game | player2: playername }
        true -> game
      end
  end

  # create new instance of the game
	def new do
    %{
       	pawns: %{"red" => createPlayerPawns("red"),
       	         "black" => createPlayerPawns("black")},

       	previously_clicked: 100,
       	previous_player: "none",
        moves: %{},
        nextChance: "red",
        player1: "none",
        player2: "none",
    }
	end

  #set the current game state
	def client_view(game) do
	IO.inspect("in client_view")
   %{

        pawns: game[:pawns],
        previously_clicked: game.previously_clicked,
       	previous_player: game.previous_player,
        moves: game[:moves],
        nextChance: game.nextChance,
        player1: game.player1,
        player2: game.player2,
    }
  	end

  #create red and black pawns and respective positions
	def createPlayerPawns(color) do

		make_pawns=[]
    if(color == "red") do
    	new_array = [{0,1},{1,3},{2,5},{3,7},{4,8},{5,10},{6,12},{7,14},{8,17},{9,19},{10,21},{11,23}];
    else
      new_array = [{0,40},{1,42},{2,44},{3,46},{4,49},{5,51},{6,53},{7,55},{8,56},{9,58},{10,60},{11,62}];
    end
    	make_pawns = Enum.map(new_array, fn{k,v} ->


  		make_pawns = make_pawns ++ %{id: k, player_color: color, position: v, defeated: false,king: false}

  		 end)
	end

  def selectPawnToRemove(game,selectedPawn,remove_pawn,id) do
    cond do
      id == selectedPawn.position + 14 ->
              rm_pawn = pawnToRemove(game,remove_pawn, id - 7)
      id == selectedPawn.position + 18 ->
              rm_pawn = pawnToRemove(game,remove_pawn, id - 9)
      id == selectedPawn.position - 14 ->
              rm_pawn = pawnToRemove(game,remove_pawn, id + 7)
      id == selectedPawn.position - 18 ->
              rm_pawn = pawnToRemove(game,remove_pawn, id + 9)
      true ->
              rm_pawn = []
    end
  end

  #move pawn based on the valid positions obtained
  def movepawn(game,id,pawn_id,color) do
    pawns = game[:pawns]
    selectedPawns = pawns[color]
    selectedPawn = Enum.at(selectedPawns,pawn_id)
    if(color == "red") do
      remove_pawn = "black"
      tempId = 55
    else
      remove_pawn = "red"
      tempId = 8
    end
    removePawns = pawns[remove_pawn]

    rm_pawn = selectPawnToRemove(game,selectedPawn,remove_pawn,id)
    #move the selected pawn
    newSelectedPawns = []
    newSelectedPawns = Enum.map(selectedPawns, fn(x) ->

      if(x.id == pawn_id ) do
        if((color =="red" and id > tempId) or (color == "black" and id<tempId)) do
          newSelectedPawns = newSelectedPawns ++ %{defeated: x.defeated, id: x.id, player_color: x.player_color, king: true, position: id}
        else
          newSelectedPawns = newSelectedPawns ++ %{defeated: x.defeated, id: x.id, player_color: x.player_color, king: x.king, position: id}
        end
      else
        newSelectedPawns = newSelectedPawns ++ x
    end end)

    #remove the pawns if jump happens
    newRemovePawns = []
    if((length rm_pawn) != 0) do

      pawn = Enum.at(rm_pawn,0)
      newRemovePawns = Enum.map(removePawns, fn(x) ->
        if(x.id == pawn.id) do
          newRemovePawns = newRemovePawns ++ %{defeated: x.defeated, id: x.id, player_color: x.player_color, king: x.king, position: -100}
        else
          newRemovePawns = newRemovePawns ++ x
      end end)
    else
      newRemovePawns = newRemovePawns ++ removePawns
    end

    if(color == "red") do
      newPawns = %{"red" => newSelectedPawns, "black" => newRemovePawns}
    else
      newPawns = %{"black" => newSelectedPawns, "red" => newRemovePawns}
    end
    #set the game states with the updated values
    game = Map.put(game, :pawns, newPawns)
    game = %{game | previously_clicked: 100 }
    game = %{game | previous_player: 'none' }
    game = %{game | moves: %{}}
    if(color == "red") do
      game = %{game | nextChance: "black"}
    else
      game = %{game | nextChance: "red"}
    end
  end

  #remove the pawn selected for removal
  def pawnToRemove(game,remove_pawn, pos) do

    pawns = game[:pawns]
    removePawns = pawns[remove_pawn]

    Enum.filter(removePawns, fn(x) ->
      x.position == pos
    end)
  end

  #get next valid positions
  def getNextPos(game,id,color) do

    pawns = game[:pawns]
    pawnType = pawns[color]
    pawn = Enum.at(pawnType,id)
    makePawns=%{};
    dictmove1 = %{};
    dictmove2 = %{};
    #condition to check for king
    cond do
      pawn.king == true ->
                    dictmove1 = getNextRedMove(game,pawn)
                    dictmove2 = getNextBlackMove(game,pawn)
                    makePawns = Map.merge(dictmove1,dictmove2)

      pawn.player_color == "red" ->
                    makePawns = getNextRedMove(game,pawn)

      true ->
                    makePawns = getNextBlackMove(game,pawn)
    end
    #set the current value for valid squares
    IO.inspect('this is getNextPos')
    IO.inspect(game)
    game = Map.put(game, :moves, makePawns)
    game = %{game | previously_clicked: id }
    game = %{game | previous_player: color }
  end

  #get next position for black pawns when opponent is red
  def getBlackPlayer(newRedMap,newBlackMap,pos0,pos1,pawn) do

      validPos = %{}
      cond do
        newRedMap[pos0]!=nil ->
               pos0 = pawn.position + 14
               if((newRedMap[pos0]!=nil) or (newBlackMap[pos0]!=nil) or (rem(pos0 + 1, 8) == 0)) do
                pos0 = 100
               end
        newBlackMap[pos0]!=nil ->
                pos0 = 100
        true ->
                pos0
      end
      cond do
        newRedMap[pos1]!=nil ->
               pos1 = pawn.position + 18
               if((newRedMap[pos1]!=nil) or (newBlackMap[pos1]!=nil) or (rem(pos1, 8) == 0)) do
                pos1 = 100
               end
        newBlackMap[pos1]!=nil ->

                pos1 = 100
        true ->
                pos1
      end
      validPos = %{pos0 => true, pos1 => true}
  end

  #get red position when opponent is black
  def getRedPlayer(newRedMap,newBlackMap,pos0,pos1,pawn) do

      validPos = %{}
      cond do
        newBlackMap[pos0]!=nil ->
               pos0 = pawn.position + 14
               if((newRedMap[pos0]!=nil) or (newBlackMap[pos0]!=nil) or (rem(pos0 + 1, 8) == 0)) do
                pos0 = 100
               end
        newRedMap[pos0]!=nil ->
                pos0 = 100
        true ->
                pos0
      end
      cond do
        newBlackMap[pos1]!=nil ->
               pos1 = pawn.position + 18
               if((newRedMap[pos1]!=nil) or (newBlackMap[pos1]!=nil) or (rem(pos1, 8) == 0)) do
                pos1 = 100
               end
        newRedMap[pos1]!=nil ->

                pos1 = 100
        true ->
                pos1
      end
      validPos = %{pos0 => true, pos1 => true}
  end

  #get next position for the red
  def getNextRedMove(game,pawn) do

    dictmove = %{}
    makepawns=[]
    pawns = game[:pawns]
    pos0 = pawn.position + 7
    pos1 = pawn.position + 9
    redPawns = pawns["red"]
    blackPawns = pawns["black"]
    newRedMap = %{}
    newBlackMap = %{}

    newRedMap = Enum.reduce(redPawns, %{},fn(x,acc) ->
      Map.put(acc, x.position, x)
    end)

    newBlackMap = Enum.reduce(blackPawns, %{},fn(x,acc) ->
      Map.put(acc, x.position, x)
    end)

    if(rem(pawn.position, 8) == 0) do
        pos0 = 100;
    end
    if(rem(pawn.position+1, 8) == 0) do
        pos1 = 100;
    end
    if(pawn.player_color == "black") do
        getBlackPlayer(newRedMap,newBlackMap,pos0,pos1,pawn)
    else
        getRedPlayer(newRedMap,newBlackMap,pos0,pos1,pawn)
    end
  end

  #get next black position when opponent is red
  def getNextBlackMove(game,pawn) do

    dictmove = %{}
    makepawns=[]
    pawns = game[:pawns]
    pos0 = pawn.position - 9
    pos1 = pawn.position - 7
    redPawns = pawns["red"]
    blackPawns = pawns["black"]
    newRedMap = %{}
    newBlackMap = %{}

    newRedMap = Enum.reduce(redPawns, %{},fn(x,acc) ->
      Map.put(acc, x.position, x)
    end)

    newBlackMap = Enum.reduce(blackPawns, %{},fn(x,acc) ->
      Map.put(acc, x.position, x)
    end)

    if(rem(pawn.position, 8) == 0) do
        pos0 = 100;
    end
    if(rem(pawn.position+1, 8) == 0) do
        pos1 = 100;
    end
    if(pawn.player_color == "black") do
        getBlackPlayerPos(newRedMap,newBlackMap,pos0,pos1,pawn)
    else
        getRedPlayerPos(newRedMap,newBlackMap,pos0,pos1,pawn)
    end
  end

  #get next red player pos when opponent is black
  def getRedPlayerPos(newRedMap,newBlackMap,pos0,pos1,pawn) do

      validPos = %{}
      cond do
        newBlackMap[pos0]!=nil ->
               pos0 = pawn.position - 18
               if((newRedMap[pos0]!=nil) or (newBlackMap[pos0]!=nil) or (rem(pos0 + 1, 8) == 0)) do
                pos0 = 100
               end
        newRedMap[pos0]!=nil ->
                pos0 = 100
        true ->
                pos0
      end
      cond do
        newBlackMap[pos1]!=nil ->
               pos1 = pawn.position - 14
               if((newRedMap[pos1]!=nil) or (newBlackMap[pos1]!=nil) or (rem(pos1, 8) == 0)) do
                pos1 = 100
               end
        newRedMap[pos1]!=nil ->
                pos1 = 100
        true ->
                pos1
      end
      validPos = %{pos0 => true, pos1 => true}
  end

  #get next black's pos when the oppenent is red
  def getBlackPlayerPos(newRedMap,newBlackMap,pos0,pos1,pawn) do

      validPos = %{}
      cond do
        newRedMap[pos0]!=nil ->
               pos0 = pawn.position - 18
               if((newRedMap[pos0]!=nil) or (newBlackMap[pos0]!=nil) or (rem(pos0 + 1, 8) == 0)) do
                pos0 = 100
               end
        newBlackMap[pos0]!=nil ->
                pos0 = 100
        true ->
                pos0
      end
      cond do
        newRedMap[pos1]!=nil ->
               pos1 = pawn.position - 14
               if((newRedMap[pos1]!=nil) or (newBlackMap[pos1]!=nil) or (rem(pos1, 8) == 0)) do
                pos1 = 100
               end
        newBlackMap[pos1]!=nil ->
                pos1 = 100
        true ->
                pos1
      end
      validPos = %{pos0 => true, pos1 => true}
  end

end
