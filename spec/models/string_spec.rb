require 'spec_helper'

describe String do
  it "apply template with hash" do
    template = 'Age: {age}, Name: {name}'
    values = {:age => 23, :name => 'Foo Bar'}
    template.apply(values).should == 'Age: 23, Name: Foo Bar'
  end

  it "replace with question marks if key is missing" do
    template = 'Age: {age}, Name: {name}'
    template.apply({}).should == 'Age: ??, Name: ??'
  end

  it "apply template with string keys" do
    template = 'Age:{age},Name:{name}'
    values = {"age" => 23, "name" => 'Foo Bar'}
    template.apply(values).should == 'Age:23,Name:Foo Bar'
  end

  describe "Strip village code" do
    it "should return the same code" do
      string = "123456789010"
      result = string.strip_village_code
      result.should == string
    end

    it "should return the same code when code is not 10-digits with last two digits ceros " do
      string = "12345678900"
      result = string.strip_village_code
      result.should == string
    end

    it "should return the same village code when code is not 8-digit and termiated with with 00" do
      string = "12345600"
      result = string.strip_village_code
      result.should == string
    end

    it "should return the first 8 digits of 10-digits village code when code are 10-digits terminated with 00" do
      string = "1234567800"
      result = string.strip_village_code

      result.should == "12345678"
      
    end
  end

  describe "highlight search" do
    before(:each) do
      @string = "vatanak monkol borey srey sonthor"
    end

    it "should highlight the 'vatanak' " do
      str = @string.highlight_search("vatanak")
      str.should == "<span class='highlight'>vatanak</span> monkol borey srey sonthor"
    end

    it "should highlight the 'rey' string " do
      str = @string.highlight_search("rey")
      str.should == "vatanak monkol bo<span class='highlight'>rey</span> s<span class='highlight'>rey</span> sonthor"
    end

    it "should highlight the 'rey' string ignoring the case " do
      str = @string.highlight_search("Rey")
      str.should == "vatanak monkol bo<span class='highlight'>rey</span> s<span class='highlight'>rey</span> sonthor"
    end


    it "should return the same string when no key is found " do
      str = @string.highlight_search("no found")
      str.should == @string
    end
    
  end
end
