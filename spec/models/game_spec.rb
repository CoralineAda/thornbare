require 'rails_helper'

RSpec.describe Game, type: :model do

  describe "#available_colors" do

    let(:game) { Game.new }
    let(:player_1) { Player.new(name: "Peter Murphy", color: Player::COLORS.first) }

    before do
      game.stub(:players).and_return([player_1])
    end

    it "does not include colors from existing players" do
      expect(game.available_colors).to_not include(Player::COLORS.first)
    end

  end

end
