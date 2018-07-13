class PeopleController < ApplicationController

  # swagger_controller :people, "People Management"
  #
  # swagger_api :index do
  #   summary "Fetches all People items"
  #   notes "This lists all the active breakfasters"
  #   param :path, :id, :integer, :required, "Person Id"
  #   response :ok
  # end

  def index
    @current = current
    @people = Person.order(:id)
    respond_to do |format|
      format.html
      format.xml  { renderrr @people }
      format.json { renderrr @people }
    end
  end

  # swagger_api :create do
  #   summary "Create a Person"
  #   param :form, :name, :string, :required, "Name of person to create"
  #   response :ok
  # end

  def create
    return head :bad_request if params[:name].blank?
    name = params[:name].gsub('@', '')

    person = Person.find_by(name: name)
    person = Person.create(name: name, done: false, passed: false) if person.nil?
    renderrr person
  end

  # swagger_api :update do
  #   summary "Update a Person"
  #   param :path, :id, :integer, :required, "Id of person to update"
  #   param :form, :name, :string, :required, "New name of person"
  #   response :ok
  # end

  def update
    person = Person.find_by(id: params[:id])
    return head :not_found if person.nil?

    return head :bad_request if params[:name].blank?

    person.update(name: params[:name].gsub('@', ''))
    renderrr person
  end

  # swagger_api :destroy do
  #   summary "Delete a Person"
  #   param :path, :id, :integer, :required, "Id of person to delete"
  #   response :no_content
  # end

  def destroy
    person = Person.find(params[:id])
    person.destroy unless person.nil?
    head :no_content
  end

  # swagger_api :next do
  #   summary "Transition to next person"
  #   response :no_content
  # end

  def next
    current.update(done: true)
    Person.all.update(passed: false)

    people = Person.where(done: false, passed: false)
    if people.empty?
      Person.all.update(done: false)
    end

    head :no_content
  end

  # swagger_api :pass do
  #   summary "Pass the current person"
  #   notes "This person will then be eligible again the next week"
  #   response :ok
  # end

  def pass
    current.update(passed: true)
    notifi

    render json: {
        type: "message",
        text: "Success! You're future breakfast will surely bring tears to our eyes"
    }
  end

  # swagger_api :notify do
  #   summary "Notify the club of the chosen breakfast bringer for the week"
  #   notes "This person is then contractually obligated to bring breakfast the following morn'"
  #   response :no_content
  # end

  def notify
    notifi
    head :no_content
  end

  private

    def notifi
      nickname = Haikunator.haikunate(0, ' ')
      fullname = current.name.split(' ').join(" \"#{nickname}\" ")
      color = Digest::MD5.hexdigest(current.name)[0, 6]

      HTTParty::Basement.default_options.update(verify: false)
      HTTParty.post(ENV['TEAMS_WEBHOOK_URL'],
        body: {
          "@context": "http://schema.org/extensions",
          "@type": "MessageCard",
          "themeColor": color,
          "title": "Yo, #{fullname}, we need breakfast tomorrow, ya dig??",
          "text": "Not going to be here this week? Click pass below.",
          "potentialAction": [
            {
              "@type": "HttpPOST",
              "name": "Pass",
              "isPrimary": true,
              "target": "https://tools-breakfast.herokuapp.com/people/pass.json"
            }
          ]
        }.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
      )
    end

    def current
      people = Person.where(done: false, passed: false)
      raise 'No current breakfast person, we\'re all going to starve :(' if people.empty?
      people.first
    end

    def renderrr(thing, status = :ok)
      respond_to do |format|
        format.html { render json: thing, status: status }
        format.xml  { render xml: thing, status: status }
        format.json { render json: thing, status: status }
      end
    end
end
