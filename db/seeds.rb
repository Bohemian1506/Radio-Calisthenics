# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 バッジシステムのシードデータを作成中..."

# バッジの初期データ
badges_data = [
  # 連続参加バッジ
  {
    name: "はじめの一歩",
    description: "3日連続でラジオ体操に参加しました！",
    icon: "🎯",
    badge_type: "streak",
    conditions: { required_days: 3 },
    sort_order: 1
  },
  {
    name: "継続の力",
    description: "7日連続でラジオ体操に参加しました！",
    icon: "⭐",
    badge_type: "streak",
    conditions: { required_days: 7 },
    sort_order: 2
  },
  {
    name: "習慣の達人",
    description: "30日連続でラジオ体操に参加しました！",
    icon: "🔥",
    badge_type: "streak",
    conditions: { required_days: 30 },
    sort_order: 3
  },
  {
    name: "不屈の精神",
    description: "100日連続でラジオ体操に参加しました！",
    icon: "💎",
    badge_type: "streak",
    conditions: { required_days: 100 },
    sort_order: 4
  },
  
  # マイルストーンバッジ
  {
    name: "体操デビュー",
    description: "初めてのラジオ体操参加、おめでとうございます！",
    icon: "🌱",
    badge_type: "milestone",
    conditions: { required_count: 1 },
    sort_order: 10
  },
  {
    name: "10回達成",
    description: "ラジオ体操に10回参加しました！",
    icon: "🎈",
    badge_type: "milestone",
    conditions: { required_count: 10 },
    sort_order: 11
  },
  {
    name: "50回達成",
    description: "ラジオ体操に50回参加しました！",
    icon: "🎊",
    badge_type: "milestone",
    conditions: { required_count: 50 },
    sort_order: 12
  },
  {
    name: "100回達成",
    description: "ラジオ体操に100回参加しました！",
    icon: "🏆",
    badge_type: "milestone",
    conditions: { required_count: 100 },
    sort_order: 13
  },
  {
    name: "365回達成",
    description: "ラジオ体操に365回参加しました！1年間お疲れさまでした！",
    icon: "👑",
    badge_type: "milestone",
    conditions: { required_count: 365 },
    sort_order: 14
  },
  
  # 月間皆勤バッジ
  {
    name: "今月皆勤賞",
    description: "今月は毎日ラジオ体操に参加しています！",
    icon: "🌟",
    badge_type: "perfect_month",
    conditions: { required_ratio: 1.0 },
    sort_order: 20
  },
  
  # 早起きバッジ
  {
    name: "早起きの鳥",
    description: "朝7時前に10回ラジオ体操に参加しました！",
    icon: "🌅",
    badge_type: "early_bird",
    conditions: { required_count: 10, cutoff_time: "07:00" },
    sort_order: 30
  },
  {
    name: "早起きの達人",
    description: "朝7時前に30回ラジオ体操に参加しました！",
    icon: "🐓",
    badge_type: "early_bird",
    conditions: { required_count: 30, cutoff_time: "07:00" },
    sort_order: 31
  },
  
  # 週末参加バッジ
  {
    name: "週末戦士",
    description: "週末に10回ラジオ体操に参加しました！",
    icon: "⚔️",
    badge_type: "weekend_warrior",
    conditions: { required_count: 10 },
    sort_order: 40
  },
  
  # 季節限定バッジ
  {
    name: "春の体操",
    description: "春にラジオ体操を20回実施しました！",
    icon: "🌸",
    badge_type: "seasonal",
    conditions: { season: "spring", required_count: 20 },
    sort_order: 50
  },
  {
    name: "夏の体操",
    description: "夏にラジオ体操を20回実施しました！",
    icon: "🌻",
    badge_type: "seasonal",
    conditions: { season: "summer", required_count: 20 },
    sort_order: 51
  },
  {
    name: "秋の体操",
    description: "秋にラジオ体操を20回実施しました！",
    icon: "🍂",
    badge_type: "seasonal",
    conditions: { season: "autumn", required_count: 20 },
    sort_order: 52
  },
  {
    name: "冬の体操",
    description: "冬にラジオ体操を20回実施しました！",
    icon: "❄️",
    badge_type: "seasonal",
    conditions: { season: "winter", required_count: 20 },
    sort_order: 53
  }
]

badges_data.each do |badge_data|
  badge = Badge.find_or_initialize_by(name: badge_data[:name])
  badge.assign_attributes(badge_data)
  badge.save!
  puts "  ✅ バッジ作成: #{badge.name}"
end

puts "🎉 バッジシステムのシードデータ作成完了！"
puts "   作成されたバッジ数: #{Badge.count}"
