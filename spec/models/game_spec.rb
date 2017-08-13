require 'rails_helper'

RSpec.describe Game, type: :model do

  describe "#available_colors" do

    let(:game) { Game.new }
    let(:player_1) { Player.new(name: "Peter Murphy", color: Player::COLORS.first) }

    before do
      game.stubs(:players).and_returns([player_1])
    end

    it "does not include colors from existing players" do
      expect(game.available_colors.count).to eq(Player::COLORS.count - 1)
    end

  end

end
