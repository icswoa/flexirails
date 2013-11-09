class StaticController < ApplicationController
  def index
  end

  protected
  def static_view
    @static_view ||= StaticView.new(params, items)
  end
  helper_method :static_view

  def items
    index = 0
    [
      "Laura",
      "Edie",
      "Nicolasa",
      "Celinda",
      "Emeline",
      "Dorcas",
      "Josette",
      "Sharell",
      "Carmela",
      "Lou",
      "Felicitas",
      "Stefany",
      "Gidget",
      "Rafaela",
      "Shirlene",
      "Luna",
      "Angila",
      "Pauline",
      "Elba",
      "Maritza",
      "Donte",
      "Clemente",
      "Nella",
      "Delaine",
      "Clark",
      "Majorie",
      "Lance",
      "Tomi",
      "Fidel",
      "Ettie",
      "Claribel",
      "Kylee",
      "Antonietta",
      "Dan",
      "Love",
      "Kandra",
      "Shantell",
      "Matt",
      "Inge",
      "Isaura",
      "Cameron",
      "Elana",
      "Stanton",
      "Tiara",
      "Jeana",
      "Daina",
      "Nikki",
      "Shondra",
      "Chelsey",
      "Jarret"
      ].map { |name|
        Static.new(index += 1, name)
      }
  end
end