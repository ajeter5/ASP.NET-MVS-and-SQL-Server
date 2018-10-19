using System;
using System.Data;
using System.Data.SqlClient;

namespace DeveloperInterview.Website.Models
{
    public class HomeIndexViewModel
    {
        public bool DatabaseSuccess { get; set; }

        /// <summary>  
        /// Get all Orders from the DB  
        /// </summary>  
        /// <returns>Datatable</returns>
        
        public DataTable GetAllOrders()
        {
            DataTable dt = new DataTable();

            string strConString = @"Data Source=localhost;Initial Catalog=MVCDatabase;Integrated Security=True";
            try
            {
                using (SqlConnection con = new SqlConnection(strConString))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("Select co.[Id], [CustomerId], [FirstName] + ' '+ [LastName] AS CustomerName, co.[AddedDate], co.[Notes] " +
                        "from [dbo].[CustomerOrder] co JOIN dbo.Customer c on c.Id = co.CustomerId", con);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
                return dt;
            }
            catch (DataException dE)
            {
                dE.ToString();
                throw;
            }
        }

        /// <summary>  
        /// Get Order by CustomerOrderId
        /// </summary>  
        /// <param name="intId"></param> 
        /// <returns>Datatable</returns>   

        public DataTable GetOrderByID(int intId)
        {
            DataTable dt = new DataTable();

            string strConString = @"Data Source=localhost;Initial Catalog=MVCDatabase;Integrated Security=True";
            try
            {
                using (SqlConnection con = new SqlConnection(strConString))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("Select co.[Id], [CustomerId], [FirstName] + ' '+ [LastName] AS CustomerName, co.[AddedDate], co.[Notes] " +
                        "from [dbo].[CustomerOrder] co JOIN dbo.Customer c on c.Id = co.CustomerId where co.id=" + intId, con);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
                return dt;
            }
            catch (DataException dE)
            {
                dE.ToString();
                throw;
            }
        }

        /// <summary>  
        /// Insert Order record into DB  
        /// </summary>  
        /// <param name="stringCustomerId"></param>  
        /// <param name="stringNotes"></param>  
        /// <returns>int</returns>  

        public int InsertOrder(int intCustomerId, string stringNotes)
        {
            string strConString = @"Data Source=localhost;Initial Catalog=MVCDatabase;Integrated Security=True";
            try
            {
                if (String.IsNullOrEmpty(intCustomerId.ToString()) || String.IsNullOrWhiteSpace(intCustomerId.ToString()))
                {
                    throw new DataException("CustomerId is null or empty.");
                }
                else
                {
                    using (SqlConnection con = new SqlConnection(strConString))
                    {
                        con.Open();

                        //string query = "Insert into [dbo].[CustomerOrder] ([CustomerId],[AddedDate]) values(@CustomerId, @AddedDate)";
                        string query = "Insert into [dbo].[CustomerOrder] ([CustomerId],[AddedDate], [Notes]) values(@CustomerId, GETDATE(), @Notes)";
                        SqlCommand cmd = new SqlCommand(query, con);
                        cmd.Parameters.AddWithValue("@CustomerId", intCustomerId);
                        cmd.Parameters.AddWithValue("@Notes", stringNotes);

                        return cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (DataException dE)
            {
                dE.ToString();
                throw;
            }
        }
    }
}