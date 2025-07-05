require 'rails_helper'

RSpec.describe StampCardImageService, type: :service do
  let(:user) { create(:user, email: 'test_user@example.com') }
  let(:year) { 2025 }
  let(:month) { 7 }
  let(:theme) { :default }
  let(:format) { :png }
  let(:service) { described_class.new(user: user, year: year, month: month, theme: theme, format: format) }

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
    it 'generates an image successfully' do
      image = service.generate

      expect(image).to be_a(MiniMagick::Image)
      expect(image.width).to eq(800)
      expect(image.height).to eq(600)
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
    describe '#create_base_image' do
      it 'creates a base white canvas image' do
        service.send(:create_base_image)

        expect(service.image).to be_a(MiniMagick::Image)
        expect(service.image.width).to eq(800)
        expect(service.image.height).to eq(600)
      end
    end

    describe '#draw_header' do
      before do
        service.send(:create_base_image)
      end

      it 'draws year and month header text' do
        expect {
          service.send(:draw_header)
        }.not_to raise_error

        expect(service.image).to be_a(MiniMagick::Image)
      end
    end

    describe '#draw_user_info' do
      before do
        service.send(:create_base_image)
      end

      it 'draws user information' do
        expect {
          service.send(:draw_user_info)
        }.not_to raise_error

        expect(service.image).to be_a(MiniMagick::Image)
      end

      context 'when user has no email' do
        let(:user) { build(:user, email: nil) }

        it 'does not draw anything' do
          allow(service).to receive(:validate_parameters)

          expect {
            service.send(:draw_user_info)
          }.not_to raise_error
        end
      end
    end
  end

  describe 'theme support' do
    context 'with different themes' do
      [ :default, :blue, :green, :purple ].each do |theme_name|
        it "generates image with #{theme_name} theme" do
          service = described_class.new(user: user, year: year, month: month, theme: theme_name)
          image = service.generate

          expect(image).to be_a(MiniMagick::Image)
          expect(image.width).to eq(800)
          expect(image.height).to eq(600)
        end
      end
    end
  end

  describe 'format support' do
    context 'with PNG format' do
      let(:format) { :png }

      it 'generates PNG image' do
        image = service.generate
        expect(image.type).to eq('PNG')
      end
    end

    context 'with PDF format' do
      let(:format) { :pdf }
      let(:temp_path) { Rails.root.join('tmp', 'test_calendar.pdf') }

      after do
        File.delete(temp_path) if File.exist?(temp_path)
      end

      it 'handles PDF generation gracefully' do
        expect {
          service.save_to_file(temp_path)
        }.not_to raise_error

        # Either PDF is created or fallback PNG
        expect(File.exist?(temp_path) || File.exist?(temp_path.to_s.sub('.pdf', '.png'))).to be true
      end
    end
  end

  describe 'error handling' do
    context 'when MiniMagick fails' do
      before do
        allow(MiniMagick::Tool::Convert).to receive(:new).and_raise(StandardError, 'MiniMagick error')
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
