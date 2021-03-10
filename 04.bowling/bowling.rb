# frozen_string_literal: true

scores = ARGV[0]

scores.chars.delete(',')

shots = []

scores.split(',').each do |score|
  if shots.size < 18
    score == 'X' ? shots.push(10, 0) : shots.push(score.to_i)
  else
    score == 'X' ? shots.push(10) : shots.push(score.to_i)
  end
end

frames = shots.each_slice(2).to_a
frames[9].push(*frames[10]) && frames.delete_at(10) if frames[10]

point = []
(0..9).each do |i|
  case i
  when 0..7
    point <<
      if frames[i][0] == 10 && frames[i + 1][0] == 10
        20 + frames[i + 2][0]
      elsif frames[i][0] == 10 && frames[i + 1][0] != 10
        10 + frames[i + 1].sum
      elsif frames[i].sum == 10
        10 + frames[i + 1][0]
      else
        frames[i].sum
      end
  when 8
    point <<
      if frames[8][0] == 10
        10 + frames[9][0..1].sum
      elsif frames[8].sum == 10
        10 + frames[9][0]
      else
        frames[8].sum
      end
  when 9
    point << frames[9].sum
  end
end

p point.sum
