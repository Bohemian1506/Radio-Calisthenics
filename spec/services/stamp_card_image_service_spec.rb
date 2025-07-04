require 'rails_helper'

RSpec.describe StampCardImageService, type: :service do
  let(:user) { create(:user, email: 'test@example.com') }
  let(:year) { 2025 }
  let(:month) { 7 }
  let(:service) { described_class.new(user: user, year: year, month: month) }

  describe '#initialize' do
    it 'initializes with valid parameters' do
      expect(service.user).to eq(user)
      expect(service.year).to eq(year)
      expect(service.month).to eq(month)
    end

    context 'with invalid parameters' do
      it 'raises error when user is nil' do
        expect {
          described_class.new(user: nil, year: year, month: month)
        }.to raise_error(ArgumentError, 'User is required')
      end

      it 'raises error when year is invalid' do
        expect {
          described_class.new(user: user, year: 1800, month: month)
        }.to raise_error(ArgumentError, 'Year must be a valid integer')
      end

      it 'raises error when month is out of range' do
        expect {
          described_class.new(user: user, year: year, month: 13)
        }.to raise_error(ArgumentError, 'Month must be between 1 and 12')
      end
    end
  end

  describe '#generate' do
    before do
      # Ensure background image exists
      background_path = Rails.root.join('app', 'assets', 'images', 'cards', 'stamp_card.png')
      expect(File.exist?(background_path)).to be true
    end

    it 'generates an image successfully' do
      image = service.generate
      
      expect(image).to be_a(MiniMagick::Image)
      expect(image.width).to eq(1000)
      expect(image.height).to eq(1480)
      expect(image.type).to eq('PNG')
    end

    it 'returns the same image on multiple calls' do
      image1 = service.generate
      image2 = service.generate
      
      expect(image1).to eq(image2)
    end
  end

  describe '#save_to_file' do
    let(:temp_path) { Rails.root.join('tmp', 'test_stamp_card.png') }
    
    after do
      File.delete(temp_path) if File.exist?(temp_path)
    end

    it 'saves the generated image to file' do
      service.save_to_file(temp_path)
      
      expect(File.exist?(temp_path)).to be true
      expect(File.size(temp_path)).to be > 0
    end

    it 'generates image if not already generated' do
      expect(service.image).to be_nil
      
      service.save_to_file(temp_path)
      
      expect(service.image).to be_a(MiniMagick::Image)
      expect(File.exist?(temp_path)).to be true
    end
  end

  describe 'private methods' do
    describe '#load_background_image' do
      it 'loads the background image' do
        service.send(:load_background_image)
        
        expect(service.image).to be_a(MiniMagick::Image)
        expect(service.image.width).to eq(1000)
        expect(service.image.height).to eq(1480)
      end

      context 'when background image does not exist' do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        it 'raises an error' do
          expect {
            service.send(:load_background_image)
          }.to raise_error(StandardError, /Background image not found/)
        end
      end
    end

    describe '#draw_year_month' do
      before do
        service.send(:load_background_image)
      end

      it 'draws year and month text' do
        expect {
          service.send(:draw_year_month)
        }.not_to raise_error
        
        expect(service.image).to be_a(MiniMagick::Image)
      end
    end

    describe '#draw_user_name' do
      before do
        service.send(:load_background_image)
      end

      it 'draws user name text' do
        expect {
          service.send(:draw_user_name)
        }.not_to raise_error
        
        expect(service.image).to be_a(MiniMagick::Image)
      end

      context 'when user has no email' do
        let(:user) { build(:user, email: nil) }

        it 'does not draw anything' do
          allow(service).to receive(:validate_parameters)
          
          expect {
            service.send(:draw_user_name)
          }.not_to raise_error
        end
      end
    end
  end

  describe 'error handling' do
    context 'when MiniMagick fails' do
      before do
        allow(MiniMagick::Image).to receive(:open).and_raise(StandardError, 'MiniMagick error')
      end

      it 'logs and re-raises the error' do
        expect(Rails.logger).to receive(:error).with(/StampCardImageService failed/)
        
        expect {
          service.generate
        }.to raise_error(StandardError, 'MiniMagick error')
      end
    end
  end
end