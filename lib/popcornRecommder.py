import numpy as np
np.set_printoptions(threshold='nan')

from scipy.optimize import minimize

import StringIO
import csv
import operator
import sys

user_input = str(sys.argv[1])
input_filename = str(sys.argv[2])
output_filename = str(sys.argv[3])

with open(input_filename) as f:
    s = StringIO.StringIO(f.read()) 
    reader = csv.reader(s, delimiter=',')
    raw = [row for row in reader]

def get_names(raw):
    return raw[0][1:]

def get_movies(raw):
    movies = []
    for i in range(1, len(raw)):
        movies.append(raw[i][0])
    return movies

def get_rating(raw):
    
    names = get_names(raw)
    movies = get_movies(raw)
    name_offset = 1
    movies_offset = 1
    
    n_names = len(names)
    n_movies = len(movies)

    has_rating = np.zeros((n_names, n_movies))
    rating = np.zeros((n_names, n_movies))
    
    for ir in range(n_movies):
        
        this_row = raw[movies_offset + ir]

        for ip in range(n_names):
            
            this_cell =  this_row[name_offset + ip]
            hr = this_cell.isdigit()
            has_rating[ip, ir] = 1 if hr else 0
            if hr:
                rating[ip, ir] = int(this_cell)
                
    return names, movies, has_rating, rating

names, movies, has_rating, rating = get_rating(raw)

# init the average matrix
average = np.zeros((len(movies),1))

# find average value for each row 
for i in range (0,len(movies)):
    sum_each_row = 0
    count_num = 0
    
    for j in range (0,len(names)):
        
        if has_rating.T[i][j] == 1:
            sum_each_row = sum_each_row + rating.T[i][j]
            count_num = count_num+1
            
    average[i][0] = sum_each_row/count_num
    
# re-init value for rating matrix
for i in range (0,len(movies)):
    for j in range (0,len(names)):
        if has_rating.T[i][j] == 1:
            rating.T[i][j] = rating.T[i][j] - average[i]

class LinearRegression: 
    
     # init all the data so it can easily accessed by all methods
    def __init__(self,has_rating,real_rating,fea,lamda,names,movies,theta,x):
        
        #has_rating and real_rating here are already transposed
        self.has_rating = has_rating
        self.real_rating = real_rating
        self.fea=fea
        self.lamda=lamda
        self.names = names
        self.movies = movies
        self.num_names = len(names)
        self.num_movies = len(movies) 
        self.theta = theta
        self.x = x
    
    #this function is use to find the gradient value for x 
    def sum_x(self,i,k,lamda):
        
        sum_x_value = 0 
        
        for j in range (0,self.num_names):
            if self.has_rating[i][j] == 1:
                sum_x_value = sum_x_value+(np.dot(self.theta[j].T,self.x[i]) - self.real_rating[i][j])*self.theta[j][k]         
        
        return sum_x_value
    
    #this function is use to find the gradient value for theta
    def sum_theta(self,j,k,lamda):
        
        sum_theta_value = 0
        
        for i in range (0,self.num_movies):
            if self.has_rating[i][j] == 1:
                sum_theta_value = sum_theta_value+(np.dot(self.theta[j].T,self.x[i]) - self.real_rating[i][j])*self.x[i][k]
        
        return sum_theta_value
                
                
                
                
    #this function will seek for the x and thata that can meet the local minimum of the function
    def gradient_descent(self,alpha,lamda):
        
        # init keep_array for both x and theta
        keep_x = np.zeros((self.num_movies,self.fea))
        keep_theta = np.zeros((self.num_names,self.fea))
        keep_x = self.x
        keep_theta = self.theta
        
        #for-loop here is used for allowing the convergent of gradient value
        for times in range(0,10000):
           
            #re-assign value to self.x and self.theta
            self.x = keep_x
            self.theta = keep_theta
            
            #set the value of x
            for i in range (0,self.num_movies):
                for k in range (0,self.fea):
                    
                    keep_x[i][k] = self.x[i][k] - alpha*(self.sum_x(i,k,lamda)+lamda*self.x[i][k])
                    
            #set the value of theta
            for j in range (0,self.num_names):
                for k in range (0,self.fea):
                    
                    keep_theta[j][k] = self.theta[j][k] - alpha*(self.sum_theta(j,k,lamda)+lamda*self.theta[j][k])
            
            #every 10000 time we reduce the step size
            if times == 9000:
                alpha = alpha/10
            
        return self.x,self.theta


#set the number of feature 
number_feature = 5

#init small guessing value for both theta and x
guess_theta = np.random.uniform(0.01,1,[len(names),number_feature])
guess_x = np.random.uniform(0.01,1,[len(movies),number_feature])

#get object from linear regression class
linear_obj = LinearRegression(has_rating.T,rating.T,number_feature,0.01,names,movies,guess_theta,guess_x)

#get return from gradient descent function (minimize x and minimize theta)
result_x, result_theta = linear_obj.gradient_descent(0.05,0.01)

#out array is the final guessing value from minimize x and theta
out = np.zeros((len(movies),len(names)))

for i in range(0,len(movies)):
            for j in range(0,len(names)):
                    out[i][j] = float("{0:.2f}".format(float((np.dot(result_theta[j].T,result_x[i])))+float((average[i]))))

class TableCell:
    
    def __init__(self, text, tc=None, color=None):
        self.text = text
        self.tc = tc
        self.color = color
    
    def to_html(self):
        return '<td>%s</td>'%self.text
    
def maketable(rating, has_rating, guess, restaurants, names,average):
    n_rests = len(restaurants)
    n_names = len(names)
    tab = np.empty((n_rests+1, n_names+1),dtype='object')
    
    for irest in range(n_rests):
        tab[irest+1,0] = restaurants[irest]

    for iname in range(n_names):
        tab[0,iname+1] = names[iname]

    for irest in range(n_rests):
        
        for iname in range(n_names):
            
            if not has_rating[irest, iname]:
                tab[irest+1, iname+1] = TableCell('<span style="color:red">%3.2f</span>'%(guess[irest, iname]))
            else:
                tab[irest+1, iname+1] = TableCell('<span style="color:blue">%3.2f</span><span style="color:red">(%3.2f)</span>'%(rating[irest, iname]+average[irest], guess[irest, iname]))
    
    #now convert tab array to nice html table
    nrow, ncol = tab.shape
    t = []
    t.append('<table>')
    for irow in range(nrow):
        t.append('<tr>')
        for icol in range(ncol):
            cell = tab[irow,icol]
            if cell is not None:
                if isinstance(cell,TableCell):
                    t.append(tab[irow, icol].to_html())
                else:
                    t.append('<td>')
                    t.append(tab[irow, icol])
                    t.append('</td>')
            else:
                t.append('<td></td>')
        t.append('</tr>')  
    t.append('</table>')
    return '\n'.join(t)

def recommend(user, output_filename):
    if user in names:
        recommend_list = {}
        sorted_list = {}
        for i in range (0,len(movies)):
            if has_rating.T[i][names.index(user)]==0:
                recommend_list[str(movies[i])] = out[i][names.index(user)]
                #recommend_list.append(out[i][names.index(user)])
        sorted_list = sorted(recommend_list.items(), key=operator.itemgetter(1),reverse=True)
        print sorted_list
        #wright output to file
        out_file = open(output_filename,'w')
        for output_name,output_rating in sorted_list:
            out_file.write("%s,%s\n" % (str(output_name),str(int(output_rating))))  
    else: 
        print "database does not contain this user"
        #wright error to file
        out_file = open(output_filename,'w')
        out_file.write("database does not contain this user")
        
recommend(user_input, output_filename)
