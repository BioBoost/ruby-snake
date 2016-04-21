require 'gosu'
require './segment'
require './snake'
require './dot'
require './vector'
require './camera'

class GameWindow < Gosu::Window
	def initialize
		super 640, 480, false
		self.caption = "Snake"
		@snake = Snake.new(self, 10)
		@score = 0
		@text_object = Gosu::Font.new(self, 'Ubuntu Sans', 24)

		# Create camera
		@camera = Camera.new(width, height)
		@camera.tick(@snake.location)

		@dots = []
		@dots << Dot.new(self, Point.new(100, 23))
		@dots << Dot.new(self, Point.new(20, 20))
		@dots << Dot.new(self, Point.new(235, 323))
		@dots << Dot.new(self, Point.new(100, 300))

		# Direction vector is based on center of window (because so are mouse coordinates)
    @center = Point.new(width/2, height/2)
    @dir_vector = (Vector.new(Point.new(0,0), @center)).to_unity

		@last_update_ms = 0
		@use_mouse = true
	end

  def update_target_location
  	if (@use_mouse)
	    # First we need to determine the direction vector from the middle of the window
	    # toward the current location of the mouse pointer
	    mouse = Point.new(mouse_x, mouse_y)
	    @dir_vector = (Vector.new(mouse, @center)).to_direction
	  else
			if button_down? Gosu::KbLeft
				@dir = Vector.new(Point.new(-1, 0), Point.new(0, 0))
			end
			if button_down? Gosu::KbRight
				@dir = Vector.new(Point.new(1, 0), Point.new(0, 0))
			end
			if button_down? Gosu::KbUp
				@dir = Vector.new(Point.new(0, -1), Point.new(0, 0))
			end
			if button_down? Gosu::KbDown
				@dir = Vector.new(Point.new(0, 1), Point.new(0, 0))
			end
	  end
  end

	def update
		update_target_location

		# Check for eaten dots
		number_of_dots = @dots.length
		@dots = @dots.select { |d| Gosu::distance(@snake.x, @snake.y, d.x, d.y) > 10 }

		if @dots.length < number_of_dots
			@snake.grow(5*(number_of_dots - @dots.length))
		end

		# Determine time from last update and take care of possible wrap around
		if (Gosu::milliseconds() > @last_update_ms)
			interval = Gosu::milliseconds() - @last_update_ms
		else
			@last_update_ms = 0
			interval = 100
		end

		if (interval >= 100)
			# Move the snake towards the mouse pointer
			@snake.move(@dir_vector)
			@camera.tick(@snake.location)
			@last_update_ms = Gosu::milliseconds()
		end

		if button_down? Gosu::KbEscape
			self.close
		end
	end

	def draw
		# Should really only render the current state of things and not change anything,
		# not even advance animations.
		# If you write draw in a functional, read-only style then you are safe.

		if @new_game
			@new_game.draw("Your Score was #{@score}", 5, 200, 100)
			@new_game.draw("Press Return to Try Again", 5, 250, 100)
			@new_game.draw("Or Escape to Close", 5, 300, 100)
		else
			Gosu::translate(@camera.x, @camera.y) do
				@snake.draw
				@dots.each do |d|
					d.draw
				end
		end
			@text_object.draw("Score: #{@score}",5,5,0)
			@text_object.draw("FPS: #{Gosu::fps}",430,5,0)
		end
	end
end

window = GameWindow.new
window.show
