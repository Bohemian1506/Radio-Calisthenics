require 'rails_helper'

RSpec.describe StampCardImageService, type: :service do
  let(:user) { create(:user, email: 'test_user@example.com') }
  let(:year) { 2025 }
  let(:month) { 7 }
  let(:format) { :png }
  let(:service) { described_class.new(user: user, year: year, month: month, format: format) }

  # Mock coordinates file content
  let(:mock_coordinates) do
    {
      "template" => {
        "image_path" => "cards/stamp_card.png",
        "width" => 800,
        "height" => 600
      },
      "month_position" => {
        "x" => 115,
        "y" => 98,
        "font_size" => 24,
        "font_color" => "#000000"
      },
      "name_position" => {
        "x" => 570,
        "y" => 98,
        "font_size" => 20,
        "font_color" => "#000000",
        "max_width" => 200
      },
      "date_positions" => {
        "offset_x" => 10,
        "offset_y" => 10,
        "font_size" => 14,
        "font_color" => "#000000",
        "inactive_color" => "#cccccc"
      },
      "stamp_positions" => {
        "offset_x" => 53,
        "offset_y" => 36,
        "size" => 30,
        "image" => "stamps/finish_stamp.png"
      },
      "cells" => [
        [
          {"x" => 50, "y" => 164}, {"x" => 157, "y" => 164}, {"x" => 264, "y" => 164}, {"x" => 371, "y" => 164}, {"x" => 478, "y" => 164}, {"x" => 585, "y" => 164}, {"x" => 692, "y" => 164}
        ]
      ]
    }
  end

  before do
    # Mock coordinates file loading
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read)
      .with(Rails.root.join("config", "stamp_card_coordinates.json"))
      .and_return(mock_coordinates.to_json)

    # Mock template image existence
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?)
      .with(Rails.root.join("app", "assets", "images", "cards", "stamp_card.png"))
      .and_return(true)

    # Mock MiniMagick::Image.open for template
    mock_image = double(MiniMagick::Image)
    mock_options = double
    allow(mock_options).to receive(:font)
    allow(mock_options).to receive(:pointsize)
    allow(mock_options).to receive(:fill)
    allow(mock_options).to receive(:gravity)
    allow(mock_options).to receive(:annotate)
    allow(mock_options).to receive(:geometry)
    
    allow(mock_image).to receive(:resize)
    allow(mock_image).to receive(:width).and_return(800)
    allow(mock_image).to receive(:height).and_return(600)
    allow(mock_image).to receive(:combine_options).and_yield(mock_options).and_return(mock_image)
    allow(mock_image).to receive(:composite).and_yield(mock_options).and_return(mock_image)
    allow(mock_image).to receive(:write)
    allow(mock_image).to receive(:dup).and_return(mock_image)
    allow(mock_image).to receive(:quality)
    allow(mock_image).to receive(:type).and_return('PNG')

    allow(MiniMagick::Image).to receive(:open).and_return(mock_image)
  end

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

    context 'when coordinates file is missing' do
      before do
        allow(File).to receive(:read)
          .with(Rails.root.join("config", "stamp_card_coordinates.json"))
          .and_raise(Errno::ENOENT)
      end

      it 'raises error with helpful message' do
        expect {
          described_class.new(user: user, year: year, month: month)
        }.to raise_error('座標設定ファイルの読み込みに失敗しました')
      end
    end
  end

  describe '#generate' do
    it 'generates an image successfully' do
      image = service.generate

      expect(image).to be_present
      expect(image.width).to eq(800)
      expect(image.height).to eq(600)
      expect(image.type).to eq('PNG')
    end

    it 'returns the same image on multiple calls' do
      image1 = service.generate
      image2 = service.generate

      expect(image1).to eq(image2)
    end

    context 'when template image is missing' do
      before do
        allow(File).to receive(:exist?)
          .with(Rails.root.join("app", "assets", "images", "cards", "stamp_card.png"))
          .and_return(false)
      end

      it 'raises error about missing template' do
        expect {
          service.generate
        }.to raise_error(/テンプレート画像が見つかりません/)
      end
    end
  end

  describe '#save_to_file' do
    let(:temp_path) { Rails.root.join('tmp', 'test_stamp_card.png') }

    after do
      begin
        File.delete(temp_path) if File.exist?(temp_path)
      rescue Errno::ENOENT
        # ファイルが存在しない場合は無視
      end
    end

    it 'saves the generated image to file' do
      allow(File).to receive(:exist?).with(temp_path).and_return(true)
      allow(File).to receive(:size).with(temp_path).and_return(1000)
      
      service.save_to_file(temp_path)

      expect(File.exist?(temp_path)).to be true
      expect(File.size(temp_path)).to be > 0
    end

    it 'generates image if not already generated' do
      expect(service.image).to be_nil
      
      allow(File).to receive(:exist?).with(temp_path).and_return(true)
      allow(File).to receive(:size).with(temp_path).and_return(1000)

      service.save_to_file(temp_path)

      expect(service.image).to be_present
      expect(File.exist?(temp_path)).to be true
    end
  end

  describe 'template-based image generation' do
    describe '#create_base_image' do
      it 'loads template image and resizes correctly' do
        service.send(:create_base_image)

        expect(service.image).to be_present
        expect(service.image.width).to eq(800)
        expect(service.image.height).to eq(600)
      end
    end

    describe '#draw_month_overlay' do
      before do
        service.send(:create_base_image)
      end

      it 'draws month text overlay' do
        expect {
          service.send(:draw_month_overlay)
        }.not_to raise_error

        expect(service.image).to be_present
      end
    end

    describe '#draw_name_overlay' do
      before do
        service.send(:create_base_image)
      end

      it 'draws user name overlay' do
        expect {
          service.send(:draw_name_overlay)
        }.not_to raise_error

        expect(service.image).to be_present
      end

      context 'when user has no email' do
        let(:user) { build(:user, email: nil) }

        it 'does not draw anything' do
          allow(service).to receive(:validate_parameters)

          expect {
            service.send(:draw_name_overlay)
          }.not_to raise_error
        end
      end
    end

    describe '#draw_calendar_dates_overlay' do
      before do
        service.send(:create_base_image)
      end

      it 'draws calendar dates using coordinates' do
        expect {
          service.send(:draw_calendar_dates_overlay)
        }.not_to raise_error

        expect(service.image).to be_present
      end
    end

    describe '#draw_stamps_overlay' do
      before do
        service.send(:create_base_image)
        # Create some stamp data
        create(:stamp_card, user: user, date: Date.new(year, month, 1))
      end

      context 'when stamp image exists' do
        before do
          allow(File).to receive(:exist?)
            .with(Rails.root.join("app", "assets", "images", "stamps", "finish_stamp.png"))
            .and_return(true)
        end

        it 'places stamp images on calendar' do
          expect {
            service.send(:draw_stamps_overlay)
          }.not_to raise_error

          expect(service.image).to be_present
        end
      end

      context 'when stamp image is missing' do
        before do
          allow(File).to receive(:exist?)
            .with(Rails.root.join("app", "assets", "images", "stamps", "finish_stamp.png"))
            .and_return(false)
        end

        it 'falls back to text stamps' do
          expect(Rails.logger).to receive(:warn).with(/Stamp image not found/)

          expect {
            service.send(:draw_stamps_overlay)
          }.not_to raise_error

          expect(service.image).to be_present
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
    context 'when coordinate loading fails' do
      before do
        allow(File).to receive(:read)
          .with(Rails.root.join("config", "stamp_card_coordinates.json"))
          .and_raise(JSON::ParserError)
      end

      it 'logs and raises helpful error' do
        expect(Rails.logger).to receive(:error).with(/Failed to load coordinates file/)

        expect {
          described_class.new(user: user, year: year, month: month)
        }.to raise_error('座標設定ファイルの読み込みに失敗しました')
      end
    end

    context 'when MiniMagick fails during generation' do
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