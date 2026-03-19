import java.util.*;

class Customer {
    int id;
    String name;
    double totalSpend;

    Customer(int id, String name, double totalSpend) {
        this.id = id;
        this.name = name;
        this.totalSpend = totalSpend;
    }
}

public class Main {
    public static void main(String[] args) {

        List<Customer> customers = new ArrayList<>();

        customers.add(new Customer(1, "Ali", 5000));
        customers.add(new Customer(2, "Sara", 8000));
        customers.add(new Customer(3, "Omar", 3000));
        customers.add(new Customer(4, "Mona", 9000));
        customers.add(new Customer(5, "Youssef", 7000));

        //  sorting using for loops 
        for (int i = 0; i < customers.size(); i++) {
            for (int j = i + 1; j < customers.size(); j++) {
                if (customers.get(i).totalSpend < customers.get(j).totalSpend) {
                    
                    // swapping
                    Customer temp = customers.get(i);
                    customers.set(i, customers.get(j));
                    customers.set(j, temp);
                }
            }
        }

        // Print top 3
        System.out.println("Top 3 Customers:");
        for (int i = 0; i < 3 && i < customers.size(); i++) {
            Customer c = customers.get(i);
            System.out.println(c.name + " - " + c.totalSpend);
        }
    }
}