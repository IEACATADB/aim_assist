class ListController < ApplicationController
  def list_items
     @items = Item.all
  end

  def list_champions
     @champs = Champion.all
  end
  def list_runes
      @runes = Rune.all
  end
end
