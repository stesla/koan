require File.dirname(__FILE__) + '/../test_helper'
require 'licensing_controller'

# Re-raise errors caught by the controller.
class LicensingController; def rescue_action(e) raise e end; end

class LicensingControllerTest < Test::Unit::TestCase
  fixtures :licenses, :customers, :products

  def setup
    @controller = LicensingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = licenses(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:licenses)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:license)
    assert assigns(:license).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:license)
  end

  def test_create
    num_licenses = License.count

    post :create, :license => {:customer_id => 1, :product_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_licenses + 1, License.count
  end

  def test_destroy
    assert_nothing_raised {
      License.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      License.find(@first_id)
    }
  end
end
